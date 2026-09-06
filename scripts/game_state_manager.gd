class_name GameStateManager
extends Node

@export var has_completed_drawing_phase: bool = false


func can_repair_parts() -> bool:
	return has_completed_drawing_phase


func mark_drawing_phase_completed() -> void:
	has_completed_drawing_phase = true
