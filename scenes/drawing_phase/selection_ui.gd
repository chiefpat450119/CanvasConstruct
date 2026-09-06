class_name SelectionUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager

@export_group("Part Buttons")
@export var head_button: Button
@export var torso_button: Button
@export var defense_button: Button
@export var weapon_button: Button

@export_group("Part Previews")
@export var head_preview: TextureRect
@export var torso_preview: TextureRect
@export var defense_preview: TextureRect
@export var weapon_preview: TextureRect

@export_group("Action Buttons")
@export var repair_button: Button
@export var upgrade_button: Button


func _ready() -> void:
	if drawing_phase_manager == null:
		push_error("SelectionUI needs a DrawingPhaseManager.")
		return

	_connect_part_button(head_button, DrawingPhaseManager.PartCategory.HEAD)
	_connect_part_button(torso_button, DrawingPhaseManager.PartCategory.TORSO)
	_connect_part_button(defense_button, DrawingPhaseManager.PartCategory.DEFENSE)
	_connect_part_button(weapon_button, DrawingPhaseManager.PartCategory.WEAPON)
	_connect_action_button(repair_button)
	_connect_action_button(upgrade_button)


func set_part_previews(
	head_texture: Texture2D,
	torso_texture: Texture2D,
	defense_texture: Texture2D,
	weapon_texture: Texture2D
) -> void:
	_set_part_preview(head_preview, head_texture)
	_set_part_preview(torso_preview, torso_texture)
	_set_part_preview(defense_preview, defense_texture)
	_set_part_preview(weapon_preview, weapon_texture)


func _connect_part_button(
	button: Button,
	category: DrawingPhaseManager.PartCategory
) -> void:
	if button != null:
		button.pressed.connect(drawing_phase_manager.select_part.bind(category))


func _connect_action_button(button: Button) -> void:
	if button != null:
		button.pressed.connect(drawing_phase_manager.select_action)


func _set_part_preview(preview: TextureRect, texture: Texture2D) -> void:
	if preview == null:
		return

	preview.texture = texture
	preview.visible = texture != null
