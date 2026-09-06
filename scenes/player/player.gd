class_name Player
extends Node2D

signal health_changed(current: int, maximum: int)
signal action_started(action: StringName)
signal defense_finished
signal died

@export var player_stats: PlayerStats
@export_range(0.0, 10.0, 0.1, "or_greater") var attack_cooldown: float = 0.5
@export_range(0.0, 10.0, 0.1, "or_greater") var defend_cooldown: float = 1.0

const DEFENSE_DURATION := 1.0

var is_defending := false
var is_dead := false
var _defense_timer := 0.0
var _attack_cooldown_timer := 0.0
var _defend_cooldown_timer := 0.0
var _weapon_rest_position: Vector2
var _shield_rest_position: Vector2

func _ready() -> void:
	_setup_stats()
	_weapon_rest_position = $Attack.position
	_shield_rest_position = $Def.position
	health_changed.emit(player_stats.curr_num_pixeles, player_stats.max_num_pixeles)
	_check_for_death()


func _process(delta: float) -> void:
	_attack_cooldown_timer = maxf(0.0, _attack_cooldown_timer - delta)
	_defend_cooldown_timer = maxf(0.0, _defend_cooldown_timer - delta)

	if _defense_timer <= 0.0:
		return

	_defense_timer = maxf(0.0, _defense_timer - delta)
	if _defense_timer == 0.0:
		is_defending = false
		_defend_cooldown_timer = defend_cooldown
		defense_finished.emit()


func attack(target: BossBase) -> void:
	if is_dead or _attack_cooldown_timer > 0.0:
		return
	if not is_instance_valid(target) or target.is_dead or player_stats == null:
		return

	_attack_cooldown_timer = attack_cooldown
	action_started.emit(&"attack")
	_play_attack_animation()
	target.take_damage(player_stats.get_weapon_damage())


func defend() -> void:
	if is_dead or _defend_cooldown_timer > 0.0 or player_stats == null:
		return

	is_defending = true
	_defense_timer = DEFENSE_DURATION
	action_started.emit(&"defend")
	_play_defend_animation()


func take_damage(amount: int) -> void:
	var damage := maxi(amount, 0)
	if is_defending:
		damage = maxi(0, damage - roundi(player_stats.get_shield_defense()))

	player_stats.take_damage(damage)
	health_changed.emit(player_stats.curr_num_pixeles, player_stats.max_num_pixeles)
	_check_for_death()


func _check_for_death() -> void:
	if is_dead or player_stats == null or not player_stats.is_dead():
		return

	is_dead = true
	is_defending = false
	print("Player died.")
	died.emit()


func _setup_stats() -> void:
	var renderer := $PlayerRenderer as PlayerRenderer
	if player_stats == null or renderer == null:
		return

	player_stats.head_damage_component = $Head/HeadDamageComponent
	player_stats.torso_damage_component = $Torso/TorsoDamageComponent
	player_stats.attack_damage_component = $Attack/AttackDamageComponent
	player_stats.defense_damage_component = $Def/DefDamageComponent
	player_stats.init_parts(
		renderer.example_a.create_runtime_instance(),
		renderer.example_h.create_runtime_instance(),
		renderer.example_d.create_runtime_instance(),
		renderer.example_t.create_runtime_instance()
	)
	player_stats.set_multipliers(1.0, 1.0, 1.0, 1.0)


func _play_attack_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Attack, "position", _weapon_rest_position + Vector2(18.0, 0.0), 0.12)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Attack, "position", _weapon_rest_position, 0.16)


func _play_defend_animation() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Def, "position", _shield_rest_position + Vector2(10.0, -12.0), 0.12)
	tween.tween_interval(DEFENSE_DURATION)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Def, "position", _shield_rest_position, 0.16)
