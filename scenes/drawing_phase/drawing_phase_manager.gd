class_name DrawingPhaseManager
extends Node

@export var selection_ui: SelectionUI
@export var repair_or_upgrade_ui: CanvasItem
@export var drawing_ui: DrawingUI

@export var head_parts: Array[HeadResource]
@export var torso_parts: Array[TorsoResource]
@export var atk_parts: Array[AtkResource]
@export var def_parts: Array[DefResource]

var _selected_category: GameStateManager.PartCategory


func _ready() -> void:
	_initialize_part_previews()
	_show_only(selection_ui)


func select_part(category: GameStateManager.PartCategory) -> void:
	_selected_category = category

	if not _has_current_part(category):
		_start_next_drawing(category)
		return

	_show_only(repair_or_upgrade_ui)


func repair_selected_part() -> void:
	var current_part := GameStateManagerInstance.get_current_part(_selected_category)
	_start_drawing(current_part.reference_part, current_part.drawing)


func upgrade_selected_part() -> void:
	_start_next_drawing(_selected_category)


func _initialize_part_previews() -> void:
	if selection_ui == null:
		return

	var head_category := GameStateManager.PartCategory.HEAD
	var torso_category := GameStateManager.PartCategory.TORSO
	var defense_category := GameStateManager.PartCategory.DEFENSE
	var weapon_category := GameStateManager.PartCategory.WEAPON

	selection_ui.set_part_previews(
		_get_preview_texture(
			GameStateManagerInstance.current_head_part,
			_get_next_part(head_category)
		),
		_get_preview_texture(
			GameStateManagerInstance.current_torso_part,
			_get_next_part(torso_category)
		),
		_get_preview_texture(
			GameStateManagerInstance.current_def_part,
			_get_next_part(defense_category)
		),
		_get_preview_texture(
			GameStateManagerInstance.current_atk_part,
			_get_next_part(weapon_category)
		)
	)


func _get_preview_texture(current_part: PlayerPart, fallback_part: PartResource) -> Texture2D:
	if current_part != null and is_instance_valid(current_part.drawing):
		var current_texture := current_part.drawing.get_texture()
		if current_texture != null:
			return current_texture

	if fallback_part != null:
		return fallback_part.reference_image

	return null


func _has_current_part(category: GameStateManager.PartCategory) -> bool:
	return GameStateManagerInstance.get_current_part(category) != null


func _start_next_drawing(category: GameStateManager.PartCategory) -> void:
	var next_part := _get_next_part(category)
	if next_part == null:
		push_warning(
			"No next part is available for category %d at index %d."
			% [category, GameStateManagerInstance.get_next_part_index(category)]
		)
		return

	if _start_drawing(next_part):
		GameStateManagerInstance.advance_next_part_index(category)


func _start_drawing(
	reference_part: PartResource,
	initial_drawing: RuntimeTexture = null
) -> bool:
	if drawing_ui == null:
		push_error("DrawingPhaseManager needs a DrawingUI.")
		return false
	if reference_part == null or reference_part.reference_image == null:
		push_warning("Cannot start drawing without a reference image.")
		return false

	drawing_ui.setup_drawing(reference_part.reference_image, null, initial_drawing)
	_show_only(drawing_ui)
	return true


func _get_next_part(category: GameStateManager.PartCategory) -> PartResource:
	var index := GameStateManagerInstance.get_next_part_index(category)
	if index < 0:
		return null

	match category:
		GameStateManager.PartCategory.HEAD:
			return head_parts[index] if index < head_parts.size() else null
		GameStateManager.PartCategory.TORSO:
			return torso_parts[index] if index < torso_parts.size() else null
		GameStateManager.PartCategory.DEFENSE:
			return def_parts[index] if index < def_parts.size() else null
		GameStateManager.PartCategory.WEAPON:
			return atk_parts[index] if index < atk_parts.size() else null

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
