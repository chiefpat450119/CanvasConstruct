extends Node

@export var curr_num_pixeles: int = 10
@export var max_num_pixeles: int = 10
@export var death_threshold: float = 0.5

@export var weapon: Resource
var _weapon_damage_multiplier: float = 0

@export var head: Resource
var _head_cooldown_multiplier: float = 0

@export var shield: Resource
var _shield_defense_multiplier: float = 0

@export var torso: Resource
var _torso_chance_multiplier: float = 0


func get_weapon_damage() -> float:
	var base_weapon_damage = 0	# TODO: Get this from weapon object
	return base_weapon_damage * _weapon_damage_multiplier

func set_weapon_damage_multiplier(damage_multiplier) -> void:
	_weapon_damage_multiplier = damage_multiplier
	
func get_head_cooldown() -> float:
	var base_head_cooldown = 0	# TODO: Get this from head object
	return base_head_cooldown * _head_cooldown_multiplier
	
func set_head_cooldown_multiplier(cooldown_multiplier) -> void:
	_head_cooldown_multiplier = cooldown_multiplier
	
func get_shield_defense() -> float:
	var base_shield_defense = 0 # TODO: Get this from shield object
	return base_shield_defense * _shield_defense_multiplier
	
func set_shield_defense_multiplier(defense_multiplier) -> void:
	_shield_defense_multiplier = defense_multiplier

func get_torso_chance() -> float:
	var base_torso_chance = 0 # TODO: Get this from torso object
	return base_torso_chance * _torso_chance_multiplier
	
func set_torso_chance_multiplier(chance_multiplier) -> void:
	_torso_chance_multiplier = chance_multiplier
	
func is_dead() -> bool:
	return curr_num_pixeles < (max_num_pixeles * death_threshold)
