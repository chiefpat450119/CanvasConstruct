class_name Player
extends Node2D

signal health_changed(current: int, maximum: int)
signal action_started(action: StringName)
signal defense_finished
signal died

@export var player_stats: PlayerStats
@export_range(0.0, 10.0, 0.1, "or_greater") var attack_cooldown: float = 0.5
@export_range(0.0, 10.0, 0.1, "or_greater") var defend_cooldown: float = 1.0

@export_group("SFX")
@export var attack_sfx: AudioStream
@export var death_sfx: AudioStream
@export var defend_sfx: AudioStream

const DEFENSE_DURATION := 1.0

var is_defending := false
var is_dead := false
var _defense_timer := 0.0
var _attack_cooldown_timer := 0.0
var _defend_cooldown_timer := 0.0


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
	if is_dead or is_defending or _attack_cooldown_timer > 0.0:
		return
	if not is_instance_valid(target) or target.is_dead or player_stats == null:
		return

	_attack_cooldown_timer = maxf(attack_cooldown, player_stats.get_head_cooldown())
	action_started.emit(&"attack")
	AudioManager.play_SFX(attack_sfx, -10)
	target.take_damage(player_stats.get_weapon_damage())


func defend() -> void:
	if is_dead or is_defending or _defend_cooldown_timer > 0.0 or player_stats == null:
		return

	is_defending = true
	_defense_timer = DEFENSE_DURATION
	action_started.emit(&"defend")
	AudioManager.play_SFX(defend_sfx, -10)


func get_attack_cooldown_remaining_ratio() -> float:
	var cooldown_duration := attack_cooldown
	if player_stats != null:
		cooldown_duration = maxf(cooldown_duration, player_stats.get_head_cooldown())
	if is_zero_approx(cooldown_duration):
		return 0.0
	return clampf(_attack_cooldown_timer / cooldown_duration, 0.0, 1.0)


func get_defend_cooldown_remaining_ratio() -> float:
	if is_defending:
		return 1.0
	if is_zero_approx(defend_cooldown):
		return 0.0
	return clampf(_defend_cooldown_timer / defend_cooldown, 0.0, 1.0)


func take_damage(amount: int) -> void:
	var damage := maxi(amount, 0)
	if is_defending:
		damage = maxi(0, damage - roundi(player_stats.get_shield_defense()))

	player_stats.take_damage(damage)
	health_changed.emit(player_stats.curr_num_pixeles, player_stats.max_num_pixeles)
	_check_for_death()


func initialize_from_parts(
	head_part: PlayerPart,
	weapon_part: PlayerPart,
	defense_part: PlayerPart,
	torso_part: PlayerPart
) -> void:
	if (
		head_part == null
		or weapon_part == null
		or defense_part == null
		or torso_part == null
	):
		push_error("Player requires head, weapon, defense, and torso parts.")
		return

	var renderer := $PlayerRenderer as PlayerRenderer
	var head_resource := head_part.reference_part as HeadResource
	var weapon_resource := weapon_part.reference_part as AtkResource
	var defense_resource := defense_part.reference_part as DefResource
	var torso_resource := torso_part.reference_part as TorsoResource
	if player_stats == null:
		push_error("Player requires PlayerStats.")
		return
	if renderer == null or head_resource == null or weapon_resource == null or defense_resource == null or torso_resource == null:
		push_error("Player parts do not match the expected resource types.")
		return

	player_stats.head_damage_component = $Head/HeadDamageComponent
	player_stats.torso_damage_component = $Torso/TorsoDamageComponent
	player_stats.attack_damage_component = $Attack/AttackDamageComponent
	player_stats.defense_damage_component = $Def/DefDamageComponent
	renderer.init(
		torso_part.drawing,
		head_part.drawing,
		weapon_part.drawing,
		defense_part.drawing
	)
	player_stats.init_parts(
		weapon_resource.create_runtime_instance() as AtkResource,
		head_resource.create_runtime_instance() as HeadResource,
		defense_resource.create_runtime_instance() as DefResource,
		torso_resource.create_runtime_instance() as TorsoResource
	)
	player_stats.set_multipliers(
		weapon_part.get_stat_multiplier(),
		head_part.get_stat_multiplier(),
		defense_part.get_stat_multiplier(),
		torso_part.get_stat_multiplier()
	)
	var parts: Array[PlayerPart] = [
		head_part,
		weapon_part,
		defense_part,
		torso_part,
	]
	player_stats.initialize_pixel_health(parts)
	health_changed.emit(player_stats.curr_num_pixeles, player_stats.max_num_pixeles)
	_check_for_death()


func get_part_drawings() -> Array[Image]:
	return [
		$Head.get_image(),
		$Attack.get_image(),
		$Def.get_image(),
		$Torso.get_image(),
	]


func _check_for_death() -> void:
	if is_dead or player_stats == null or not player_stats.is_dead():
		return

	is_dead = true
	is_defending = false
	print("Player died.")
	AudioManager.play_SFX(death_sfx, -10)
	died.emit()
