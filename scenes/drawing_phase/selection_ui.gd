class_name SelectionUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager

@export_group("Parts")
@export var head_ui: PartUI
@export var torso_ui: PartUI
@export var defense_ui: PartUI
@export var weapon_ui: PartUI

@export_group("Action Buttons")
@export var fight_button: TextureButton


func _ready() -> void:
	if drawing_phase_manager == null:
		push_error("SelectionUI needs a DrawingPhaseManager.")
		return

	_connect_part(head_ui, GameStateManager.PartCategory.HEAD)
	_connect_part(torso_ui, GameStateManager.PartCategory.TORSO)
	_connect_part(defense_ui, GameStateManager.PartCategory.DEFENSE)
	_connect_part(weapon_ui, GameStateManager.PartCategory.WEAPON)
	_connect_action_button(fight_button, drawing_phase_manager.fight)


func set_part_previews(
	head_texture: Texture2D,
	torso_texture: Texture2D,
	defense_texture: Texture2D,
	weapon_texture: Texture2D
) -> void:
	_set_part_preview(head_ui, head_texture)
	_set_part_preview(torso_ui, torso_texture)
	_set_part_preview(defense_ui, defense_texture)
	_set_part_preview(weapon_ui, weapon_texture)


func set_fight_button_visible(is_visible: bool) -> void:
	if fight_button != null:
		fight_button.visible = is_visible


func disable_part(category: GameStateManager.PartCategory) -> void:
	var part := _get_part_ui(category)
	if part != null:
		part.disable()


func set_part_similarity(
	category: GameStateManager.PartCategory,
	similarity: float
) -> void:
	var part := _get_part_ui(category)
	if part != null:
		part.set_similarity(similarity)


func _get_part_ui(category: GameStateManager.PartCategory) -> PartUI:
	match category:
		GameStateManager.PartCategory.HEAD:
			return head_ui
		GameStateManager.PartCategory.TORSO:
			return torso_ui
		GameStateManager.PartCategory.DEFENSE:
			return defense_ui
		GameStateManager.PartCategory.WEAPON:
			return weapon_ui

	return null


func _connect_part(
	part: PartUI,
	category: GameStateManager.PartCategory
) -> void:
	if part != null:
		part.selected.connect(drawing_phase_manager.select_part.bind(category))


func _connect_action_button(button: BaseButton, action: Callable) -> void:
	if button != null:
		button.pressed.connect(action)


func _set_part_preview(part: PartUI, texture: Texture2D) -> void:
	if part != null:
		part.set_preview(texture)
