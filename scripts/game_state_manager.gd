class_name GameStateManager
extends Node

@export var has_completed_drawing_phase: bool = false
@export var boss_scenes: Array[PackedScene] = []

var next_boss_index: int = 0


func can_repair_parts() -> bool:
	return has_completed_drawing_phase


func mark_drawing_phase_completed() -> void:
	has_completed_drawing_phase = true
