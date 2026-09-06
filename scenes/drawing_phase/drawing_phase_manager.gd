class_name DrawingPhaseManager
extends Node

@export var selection_ui: CanvasItem
@export var repair_or_upgrade_ui: CanvasItem
@export var drawing_ui: CanvasItem


func _ready() -> void:
	_show_only(selection_ui)


func select_part() -> void:
	_show_only(repair_or_upgrade_ui)


func select_action() -> void:
	_show_only(drawing_ui)


func _show_only(active_ui: CanvasItem) -> void:
	_set_ui_enabled(selection_ui, active_ui == selection_ui)
	_set_ui_enabled(repair_or_upgrade_ui, active_ui == repair_or_upgrade_ui)
	_set_ui_enabled(drawing_ui, active_ui == drawing_ui)


func _set_ui_enabled(ui: CanvasItem, is_enabled: bool) -> void:
	if ui == null:
		return

	ui.visible = is_enabled
	ui.process_mode = (
		Node.PROCESS_MODE_INHERIT if is_enabled else Node.PROCESS_MODE_DISABLED
	)
