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
func switch_to_drawing_phase() -> void:
	get_tree().change_scene_to_file(drawing_phase_scene_path)


## Replaces the current scene with combat and spawns the next configured boss.
func switch_to_combat_phase() -> void:
	var scene_tree := get_tree()
	scene_tree.change_scene_to_file(combat_phase_scene_path)
	await scene_tree.scene_changed
	var combat_phase := scene_tree.current_scene as CombatPhaseManager
	initialize_combat_phase(combat_phase)


func initialize_combat_phase(combat_phase_manager: CombatPhaseManager) -> void:
	combat_phase_manager.initialize(boss_scenes[next_boss_index])
	next_boss_index += 1
