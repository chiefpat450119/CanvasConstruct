@tool
class_name DoubleHitMechanic
extends PartMechanic

func modify_attack_hit_count(hit_count: int, _context: Dictionary) -> int:
	return hit_count * 2
