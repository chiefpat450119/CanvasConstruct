class_name PlayerStats
extends Node

@export var curr_num_pixeles: int = 10
@export var max_num_pixeles: int = 10
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
	var base_weapon_damage: float = weapon_part.get_damage()
	return base_weapon_damage * _weapon_damage_multiplier
	
func get_head_cooldown() -> float:
	var base_head_cooldown = head_part.get_cooldown()
	return base_head_cooldown * _head_cooldown_multiplier
	
func get_shield_defense() -> float:
	var base_shield_defense = defense_part.get_defense()
	return base_shield_defense * _shield_defense_multiplier
	

func get_torso_chance() -> float:
	var base_torso_chance = torso_part.get_torso_chance()
	return base_torso_chance * _torso_chance_multiplier
	
	
func is_dead() -> bool:
	return curr_num_pixeles < (max_num_pixeles * death_threshold)

func take_damage(pixel_count: int) -> void:
	if pixel_count <= 0:
		return

	var available_parts: Array[DamagableComponent] = []
	var body_parts: Array[DamagableComponent] = [head_damage_component, defense_damage_component, torso_damage_component, attack_damage_component]
	for body_part: DamagableComponent in body_parts:
		if body_part != null and body_part.can_receive_damage():
			available_parts.append(body_part)

	if available_parts.is_empty():
		return

	var damaged_part: DamagableComponent = available_parts.pick_random()
	curr_num_pixeles = maxi(0, curr_num_pixeles - damaged_part.damage_pixels(pixel_count))