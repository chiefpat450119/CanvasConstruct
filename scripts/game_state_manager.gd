class_name GameStateManager
extends Node

@export var has_completed_drawing_phase: bool = false
@export var boss_scenes: Array[PackedScene] = []
@export_file("*.tscn") var drawing_phase_scene_path := "res://scenes/drawing_phase/drawing_phase.tscn"
@export_file("*.tscn") var combat_phase_scene_path := "res://scenes/combat_phase/combat_phase.tscn"

var next_boss_index: int = 0


func can_repair_parts() -> bool:
	return has_completed_drawing_phase


func mark_drawing_phase_completed() -> void:
	has_completed_drawing_phase = true


## Replaces the current scene with the drawing phase scene.
func switch_to_drawing_phase() -> Error:
	if drawing_phase_scene_path.is_empty():
		return ERR_UNCONFIGURED
	return get_tree().change_scene_to_file(drawing_phase_scene_path)


## Replaces the current scene with combat and spawns the next configured boss.
func switch_to_combat_phase() -> Error:
	if combat_phase_scene_path.is_empty():
		return ERR_UNCONFIGURED
	var scene_tree := get_tree()
	if scene_tree == null:
		return ERR_UNCONFIGURED
	if next_boss_index < 0 or next_boss_index >= boss_scenes.size():
		return ERR_DOES_NOT_EXIST
	if boss_scenes[next_boss_index] == null:
		return ERR_UNCONFIGURED

	var change_error := scene_tree.change_scene_to_file(combat_phase_scene_path)
	if change_error != OK:
		return change_error

	await scene_tree.scene_changed
	var combat_phase := scene_tree.current_scene as CombatPhaseManager
	if combat_phase == null:
		return ERR_INVALID_DATA
	return initialize_combat_phase(combat_phase)


func initialize_combat_phase(combat_phase_manager: CombatPhaseManager) -> Error:
	if combat_phase_manager == null:
		return ERR_INVALID_PARAMETER
	if next_boss_index < 0 or next_boss_index >= boss_scenes.size():
		return ERR_DOES_NOT_EXIST

	var boss_scene := boss_scenes[next_boss_index]
	if boss_scene == null:
		return ERR_UNCONFIGURED

	var initialize_error := combat_phase_manager.initialize(boss_scene)
	if initialize_error != OK:
		return initialize_error

	next_boss_index += 1
	return OK
