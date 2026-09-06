class_name DrawingPhaseManager
extends Node

@export var selection_ui: SelectionUI
@export var repair_or_upgrade_ui: CanvasItem
@export var drawing_ui: CanvasItem

@export var head_parts: Array[HeadResource]
@export var torso_parts: Array[TorsoResource]
@export var atk_parts: Array[AtkResource]
@export var def_parts: Array[DefResource]


func _ready() -> void:
	_initialize_part_previews()
	_show_only(selection_ui)


func select_part() -> void:
	_show_only(repair_or_upgrade_ui)


func select_action() -> void:
	_show_only(drawing_ui)


func _initialize_part_previews() -> void:
	if selection_ui == null:
		return

	var head_fallback: HeadResource = null
	var torso_fallback: TorsoResource = null
	var atk_fallback: AtkResource = null
	var def_fallback: DefResource = null

	head_fallback = head_parts[0]
	torso_fallback = torso_parts[0]
	atk_fallback = atk_parts[0]
	def_fallback = def_parts[0]

	selection_ui.set_part_previews(
		_get_preview_texture(GameStateManagerInstance.current_head_part, head_fallback),
		_get_preview_texture(GameStateManagerInstance.current_torso_part, torso_fallback),
		_get_preview_texture(GameStateManagerInstance.current_def_part, def_fallback),
		_get_preview_texture(GameStateManagerInstance.current_atk_part, atk_fallback)
	)


func _get_preview_texture(current_part: PlayerPart, fallback_part: PartResource) -> Texture2D:
	if current_part != null and is_instance_valid(current_part.drawing):
		var current_texture := current_part.drawing.get_texture()
		if current_texture != null:
			return current_texture

	if fallback_part != null:
		return fallback_part.reference_image

	return null


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
