class_name CombatUI
extends CanvasLayer

signal attack_requested
signal defend_requested

@export var attack_button: Button
@export var defend_button: Button
@export var player_health_bar: ProgressBar
@export var boss_health_bar: ProgressBar


func _ready() -> void:
	attack_button.pressed.connect(attack_requested.emit)
	defend_button.pressed.connect(defend_requested.emit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		attack_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"block"):
		defend_requested.emit()
		get_viewport().set_input_as_handled()


func bind_combatant(player: Player, boss: BossBase) -> void:
	player.health_changed.connect(_on_player_health_changed)
	boss.health_changed.connect(_on_boss_health_changed)
	_on_player_health_changed(player.player_stats.curr_num_pixeles, player.player_stats.max_num_pixeles)
	_on_boss_health_changed(boss.health, boss.health)


func clear_boss() -> void:
	boss_health_bar.value = 0.0
	boss_health_bar.max_value = 1.0


func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health_bar.max_value = maximum
	player_health_bar.value = current


func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current
