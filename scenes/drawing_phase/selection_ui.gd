class_name SelectionUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager

@export_group("Part Buttons")
@export var head_button: Button
@export var torso_button: Button
@export var defense_button: Button
@export var weapon_button: Button

@export_group("Part Previews")
@export var head_preview: Button
@export var torso_preview: Button
@export var defense_preview: Button
@export var weapon_preview: Button

@export_group("Part Similarities")
@export var head_similarity_label: Label
@export var torso_similarity_label: Label
@export var defense_similarity_label: Label
@export var weapon_similarity_label: Label

@export_group("Action Buttons")
@export var fight_button: TextureButton


func _ready() -> void:
	if drawing_phase_manager == null:
		push_error("SelectionUI needs a DrawingPhaseManager.")
		return

	_connect_part_button(head_button, GameStateManager.PartCategory.HEAD)
	_connect_part_button(torso_button, GameStateManager.PartCategory.TORSO)
	_connect_part_button(defense_button, GameStateManager.PartCategory.DEFENSE)
	_connect_part_button(weapon_button, GameStateManager.PartCategory.WEAPON)
	_connect_action_button(fight_button, drawing_phase_manager.fight)


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


func disable_part(category: GameStateManager.PartCategory) -> void:
	var button := _get_part_button(category)
	if button != null:
		button.disabled = true


func set_part_similarity(
	category: GameStateManager.PartCategory,
	similarity: float
) -> void:
	var label := _get_similarity_label(category)
	if label != null:
		label.text = "%d%%" % roundi(clampf(similarity, 0.0, 1.0) * 100.0)


func _get_part_button(category: GameStateManager.PartCategory) -> Button:
	match category:
		GameStateManager.PartCategory.HEAD:
			return head_button
		GameStateManager.PartCategory.TORSO:
			return torso_button
		GameStateManager.PartCategory.DEFENSE:
			return defense_button
		GameStateManager.PartCategory.WEAPON:
			return weapon_button

	return null


func _get_similarity_label(category: GameStateManager.PartCategory) -> Label:
	match category:
		GameStateManager.PartCategory.HEAD:
			return head_similarity_label
		GameStateManager.PartCategory.TORSO:
			return torso_similarity_label
		GameStateManager.PartCategory.DEFENSE:
			return defense_similarity_label
		GameStateManager.PartCategory.WEAPON:
			return weapon_similarity_label

	return null


func _connect_part_button(
	button: Button,
	category: GameStateManager.PartCategory
) -> void:
	if button != null:
		button.pressed.connect(drawing_phase_manager.select_part.bind(category))


func _connect_action_button(button: BaseButton, action: Callable) -> void:
	if button != null:
		button.pressed.connect(action)


func _set_part_preview(preview: Button, texture: Texture2D) -> void:
	if preview == null:
		return

	preview.icon = texture
	preview.visible = texture != null
