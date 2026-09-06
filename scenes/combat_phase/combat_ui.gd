class_name CombatUI
extends CanvasLayer

signal attack_requested
signal defend_requested

@export var attack_button: Button
@export var defend_button: Button
@export var attack_cooldown_overlay: TextureProgressBar
@export var defend_cooldown_overlay: TextureProgressBar
@export var player_health_bar: ProgressBar
@export var boss_health_bar: ProgressBar

var _player: Player


func _ready() -> void:
	attack_button.pressed.connect(attack_requested.emit)
	defend_button.pressed.connect(defend_requested.emit)
	_update_cooldowns()


func _process(_delta: float) -> void:
	_update_cooldowns()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack") and not attack_button.disabled:
		attack_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"block") and not defend_button.disabled:
		defend_requested.emit()
		get_viewport().set_input_as_handled()


func bind_combatant(player: Player, boss: BossBase) -> void:
	_player = player
	player.health_changed.connect(_on_player_health_changed)
	boss.health_changed.connect(_on_boss_health_changed)
	_on_player_health_changed(player.player_stats.curr_num_pixeles, player.player_stats.max_num_pixeles)
	_on_boss_health_changed(boss.health, boss.health)
	_update_cooldowns()


func clear_boss() -> void:
	boss_health_bar.value = 0.0
	boss_health_bar.max_value = 1.0


func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health_bar.max_value = maximum
	player_health_bar.value = current


func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current


func _update_cooldowns() -> void:
	var has_player := is_instance_valid(_player)
	var attack_ratio := _player.get_attack_cooldown_remaining_ratio() if has_player else 0.0
	var defend_ratio := _player.get_defend_cooldown_remaining_ratio() if has_player else 0.0

	attack_cooldown_overlay.value = attack_ratio * attack_cooldown_overlay.max_value
	attack_cooldown_overlay.visible = attack_ratio > 0.0
	defend_cooldown_overlay.value = defend_ratio * defend_cooldown_overlay.max_value
	defend_cooldown_overlay.visible = defend_ratio > 0.0

	attack_button.disabled = not has_player or _player.is_dead or _player.is_defending or attack_ratio > 0.0
	defend_button.disabled = not has_player or _player.is_dead or _player.is_defending or defend_ratio > 0.0
