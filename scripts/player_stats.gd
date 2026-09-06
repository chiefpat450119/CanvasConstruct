class_name PlayerStats
extends Node

@export var curr_num_pixeles: int = 100
@export var max_num_pixeles: int = 100
@export var death_threshold: float = 0.5

var weapon_part: AtkResource
var _weapon_damage_multiplier: float = 0

var head_part: HeadResource
var _head_cooldown_multiplier: float = 0

var defense_part: DefResource
var _shield_defense_multiplier: float = 0

var torso_part: TorsoResource
var _torso_chance_multiplier: float = 0

@export var head_damage_component: DamagableComponent
@export var torso_damage_component: DamagableComponent
@export var attack_damage_component: DamagableComponent
@export var defense_damage_component: DamagableComponent


func init_parts(weapon: AtkResource, head: HeadResource, defense: DefResource, torso: TorsoResource) -> void:
	weapon_part = weapon
	head_part = head
	defense_part = defense
	torso_part = torso

func set_multipliers(weapon_multiplier: float, head_multiplier: float, defense_multiplier: float, torso_multiplier: float) -> void:
	_weapon_damage_multiplier = weapon_multiplier
	_head_cooldown_multiplier = head_multiplier
	_shield_defense_multiplier = defense_multiplier
	_torso_chance_multiplier = torso_multiplier

func get_weapon_damage() -> float:
	if weapon_part == null:
		return 0.0
	var base_weapon_damage: float = weapon_part.attack_damage
	return weapon_part.modify_attack_damage(base_weapon_damage * _weapon_damage_multiplier)
	
func get_head_cooldown() -> float:
	if head_part == null:
		return 0.0
	return head_part.modify_cooldown(
		head_part.cooldown_seconds * _head_cooldown_multiplier
	)
	
func get_shield_defense() -> float:
	if defense_part == null:
		return 0.0
	var base_shield_defense: float = defense_part.defense
	return defense_part.modify_defense(base_shield_defense * _shield_defense_multiplier)
	

func get_torso_chance() -> float:
	if torso_part == null:
		return 0.0
	return clampf(
		torso_part.damage_avoidance_chance * _torso_chance_multiplier,
		0.0,
		1.0
	)
	
	
func is_dead() -> bool:
	return curr_num_pixeles <= (max_num_pixeles * death_threshold)

func take_damage(pixel_count: int) -> int:
	if pixel_count <= 0:
		return 0

	if randf() < get_torso_chance():
		print("Player dodged the attack.")
		return 0

	var available_parts: Array[DamagableComponent] = []
	var body_parts: Array[DamagableComponent] = [head_damage_component, defense_damage_component, torso_damage_component, attack_damage_component]
	for body_part: DamagableComponent in body_parts:
		if body_part != null and body_part.can_receive_damage():
			available_parts.append(body_part)

	if available_parts.is_empty():
		return 0

	var damaged_part: DamagableComponent = available_parts.pick_random()
	var removed_pixels := damaged_part.damage_pixels(pixel_count)
	curr_num_pixeles = maxi(0, curr_num_pixeles - removed_pixels)
	return removed_pixels