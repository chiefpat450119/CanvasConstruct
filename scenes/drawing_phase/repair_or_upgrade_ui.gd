class_name RepairOrUpgradeUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager
@export var repair_button: Button
@export var upgrade_button: Button


func _ready() -> void:
	if drawing_phase_manager == null:
		push_error("RepairOrUpgradeUI needs a DrawingPhaseManager.")
		return

	_connect_action_button(repair_button, drawing_phase_manager.repair_selected_part)
	_connect_action_button(upgrade_button, drawing_phase_manager.upgrade_selected_part)


func _connect_action_button(button: Button, action: Callable) -> void:
	if button != null:
		button.pressed.connect(action)
