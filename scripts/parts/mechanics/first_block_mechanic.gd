@tool
class_name FirstBlockMechanic
extends PartMechanic

var _is_available: bool = true

func reset_runtime_state() -> void:
	_is_available = true

func modify_incoming_damage(damage: float, context: Dictionary) -> float:
	if not _is_available or damage <= 0.0:
		return damage
	if not bool(context.get(&"is_blocking", false)):
		return damage

	_is_available = false
	context[&"damage_was_fully_blocked"] = true
	return 0.0
