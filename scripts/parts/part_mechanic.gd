@tool
class_name PartMechanic
extends Resource

@export var display_name: String = ""
@export_multiline var description: String = ""


## Creates a per-player copy. Never store match state on the saved template.
func create_runtime_instance() -> PartMechanic:
	var runtime := duplicate(true) as PartMechanic
	runtime.reset_runtime_state()
	return runtime


## Override to reset temporary state when a player or game is initialized.
func reset_runtime_state() -> void:
	pass


func modify_incoming_damage(damage: float, _context: Dictionary) -> float:
	return damage


func modify_attack_damage(damage: float, _context: Dictionary) -> float:
	return damage


func modify_attack_hit_count(hit_count: int, _context: Dictionary) -> int:
	return hit_count


func modify_cooldown(cooldown_seconds: float, _context: Dictionary) -> float:
	return cooldown_seconds


func modify_defense(defense: float, _context: Dictionary) -> float:
	return defense


## Override for a mechanic that reacts to a game-specific event not covered by
## the stat hooks above.
func on_event(_event: StringName, _context: Dictionary) -> void:
	pass
