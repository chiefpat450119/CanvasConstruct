@tool
class_name BonusDamageMechanic
extends PartMechanic

@export var bonus_damage: float = 10.0


func modify_attack_damage(damage: float, _context: Dictionary) -> float:
	return damage + bonus_damage
