class_name GameStateManager
extends Node

enum PartCategory {
	HEAD,
	TORSO,
	DEFENSE,
	WEAPON,
}

@export var has_completed_drawing_phase: bool = false
@export var boss_scenes: Array[PackedScene] = [
	preload("res://scenes/bosses/orc_boss.tscn"),
	preload("res://scenes/bosses/orc_boss.tscn"),
	preload("res://scenes/bosses/orc_boss.tscn"),
]
@export_file("*.tscn") var drawing_phase_scene_path := "res://scenes/drawing_phase/drawing_phase.tscn"
@export_file("*.tscn") var combat_phase_scene_path := "res://scenes/combat_phase/combat_phase.tscn"
@export_file("*.tscn") var victory_scene_path := "res://scenes/victory/victory.tscn"
@export_file("*.tscn") var defeat_scene_path := "res://scenes/defeat/defeat.tscn"

var next_boss_index: int = 0
var current_head_part: PlayerPart = null
var current_atk_part: PlayerPart = null
var current_def_part: PlayerPart = null
var current_torso_part: PlayerPart = null
var _next_part_indices: Dictionary = {
	PartCategory.HEAD: 0,
	PartCategory.TORSO: 0,
	PartCategory.DEFENSE: 0,
	PartCategory.WEAPON: 0,
}


func can_repair_parts() -> bool:
	return has_completed_drawing_phase


func mark_drawing_phase_completed() -> void:
	has_completed_drawing_phase = true


func reset_run() -> void:
	AudioManager.play_build_music()
	has_completed_drawing_phase = false
	next_boss_index = 0
	current_head_part = null
	current_atk_part = null
	current_def_part = null
	current_torso_part = null
	for category in _next_part_indices:
		_next_part_indices[category] = 0


func has_all_player_parts() -> bool:
	return current_head_part != null and current_atk_part != null and current_def_part != null and current_torso_part != null


func update_current_part_drawings(drawings: Array[Image]) -> void:
	if drawings.size() != 4 or not has_all_player_parts():
		return

	current_head_part.drawing = drawings[0]
	current_atk_part.drawing = drawings[1]
	current_def_part.drawing = drawings[2]
	current_torso_part.drawing = drawings[3]


func set_current_part(part: PlayerPart) -> void:
	if part.reference_part is HeadResource:
		current_head_part = part
	elif part.reference_part is AtkResource:
		current_atk_part = part
	elif part.reference_part is DefResource:
		current_def_part = part
	elif part.reference_part is TorsoResource:
		current_torso_part = part


func get_current_part(category: PartCategory) -> PlayerPart:
	match category:
		PartCategory.HEAD:
			return current_head_part
		PartCategory.TORSO:
			return current_torso_part
		PartCategory.DEFENSE:
			return current_def_part
		PartCategory.WEAPON:
			return current_atk_part

	return null


func get_next_part_index(category: PartCategory) -> int:
	return _next_part_indices.get(category, 0)


func advance_next_part_index(category: PartCategory) -> void:
	_next_part_indices[category] = get_next_part_index(category) + 1


func get_current_parts() -> Array[PlayerPart]:
	var parts: Array[PlayerPart] = [
		current_head_part,
		current_atk_part,
		current_def_part,
		current_torso_part,
	]
	return parts


func switch_to_drawing_phase() -> void:
	AudioManager.play_build_music()
	get_tree().change_scene_to_file(drawing_phase_scene_path)


func switch_to_combat_phase() -> void:
	AudioManager.play_combat_music()
	var scene_tree := get_tree()
	scene_tree.change_scene_to_file(combat_phase_scene_path)
	await scene_tree.scene_changed
	var combat_phase := scene_tree.current_scene as CombatPhaseManager
	initialize_combat_phase(combat_phase)


func initialize_combat_phase(combat_phase_manager: CombatPhaseManager) -> void:
	var result := combat_phase_manager.initialize(
		boss_scenes[next_boss_index],
		get_current_parts()
	)
	if result != OK:
		push_error("Could not initialize combat phase: %s" % error_string(result))
		return

	combat_phase_manager.victory.connect(_on_combat_victory.bind(combat_phase_manager))
	combat_phase_manager.defeat.connect(_on_combat_defeat)
	next_boss_index += 1


func _on_combat_victory(combat_phase_manager: CombatPhaseManager) -> void:
	update_current_part_drawings(combat_phase_manager.get_player_drawings())
	if next_boss_index >= 3:
		get_tree().change_scene_to_file(victory_scene_path)
	else:
		switch_to_drawing_phase()


func _on_combat_defeat() -> void:
	get_tree().change_scene_to_file(defeat_scene_path)
