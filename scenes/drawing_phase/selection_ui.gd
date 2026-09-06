class_name SelectionUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager

@export_group("Part Buttons")
@export var head_button: Button
@export var torso_button: Button
@export var defense_button: Button
@export var weapon_button: Button

@export_group("Action Buttons")
@export var repair_button: Button
@export var upgrade_button: Button


func _ready() -> void:
	if drawing_phase_manager == null:
		push_error("SelectionUI needs a DrawingPhaseManager.")
		return

	_connect_part_button(head_button)
	_connect_part_button(torso_button)
	_connect_part_button(defense_button)
	_connect_part_button(weapon_button)
	_connect_action_button(repair_button)
	_connect_action_button(upgrade_button)


func _connect_part_button(button: Button) -> void:
	if button != null:
		button.pressed.connect(drawing_phase_manager.select_part)


func _connect_action_button(button: Button) -> void:
	if button != null:
		button.pressed.connect(drawing_phase_manager.select_action)
