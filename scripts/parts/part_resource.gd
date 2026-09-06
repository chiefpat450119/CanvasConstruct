@tool
class_name PartResource
extends Resource

## Shared data for every player part.
##
## Treat saved part resources as templates. Call [method create_runtime_instance]
## when constructing a player so stateful mechanics are unique to that player.

@export var display_name: String = ""
@export_multiline var description: String = ""
@export var reference_image: Texture2D
@export var mechanics: Array[PartMechanic] = []


## Returns a copy safe to mutate during a match. Mechanics are copied
## explicitly because resources stored inside arrays may otherwise stay shared.
func create_runtime_instance() -> PartResource:
	var runtime := duplicate(false) as PartResource
	runtime.mechanics = []

	for mechanic in mechanics:
		if mechanic != null:
			runtime.mechanics.append(mechanic.create_runtime_instance())

	runtime.reset_runtime_state()
	return runtime


## Resets temporary mechanic state without rebuilding the player's part.
func reset_runtime_state() -> void:
	for mechanic in mechanics:
		if mechanic != null:
			mechanic.reset_runtime_state()


func modify_incoming_damage(damage: float, context: Dictionary = {}) -> float:
	var result := maxf(damage, 0.0)
	for mechanic in mechanics:
		if mechanic != null:
			result = maxf(mechanic.modify_incoming_damage(result, context), 0.0)
	return result


func modify_attack_damage(damage: float, context: Dictionary = {}) -> float:
	var result := maxf(damage, 0.0)
	for mechanic in mechanics:
		if mechanic != null:
			result = maxf(mechanic.modify_attack_damage(result, context), 0.0)
	return result


func modify_attack_hit_count(hit_count: int, context: Dictionary = {}) -> int:
	var result := maxi(hit_count, 0)
	for mechanic in mechanics:
		if mechanic != null:
			result = maxi(mechanic.modify_attack_hit_count(result, context), 0)
	return result


func modify_cooldown(cooldown_seconds: float, context: Dictionary = {}) -> float:
	var result := maxf(cooldown_seconds, 0.0)
	for mechanic in mechanics:
		if mechanic != null:
			result = maxf(mechanic.modify_cooldown(result, context), 0.0)
	return result


func modify_defense(defense: float, context: Dictionary = {}) -> float:
	var result := maxf(defense, 0.0)
	for mechanic in mechanics:
		if mechanic != null:
			result = maxf(mechanic.modify_defense(result, context), 0.0)
	return result


## Dispatches less common gameplay events to custom mechanics. Event-specific
## data can be placed in [param context].
func notify_event(event: StringName, context: Dictionary = {}) -> void:
	for mechanic in mechanics:
		if mechanic != null:
			mechanic.on_event(event, context)
