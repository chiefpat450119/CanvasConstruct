class_name SelectionUI
extends Control

@export var drawing_phase_manager: DrawingPhaseManager

@export_group("Parts")
@export var head_ui: PartUI
@export var torso_ui: PartUI
@export var defense_ui: PartUI
@export var weapon_ui: PartUI

@export_group("Total Completion")
@export var total_progress_bar: TotalProgressBar

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


func set_part_preview(
	category: GameStateManager.PartCategory,
	texture: Texture2D
) -> void:
	var part := _get_part_ui(category)
	if part != null:
		part.set_preview(texture)


func set_part_reference(
	category: GameStateManager.PartCategory,
	reference_part: PartResource,
	stat_multiplier: float = 1.0
) -> void:
	var part := _get_part_ui(category)
	if part != null:
		part.set_reference_part(reference_part, stat_multiplier)


func set_fight_button_visible(is_visible: bool) -> void:
	if fight_button != null:
		fight_button.visible = is_visible


func set_total_completion(completion: float) -> void:
	if total_progress_bar != null:
		total_progress_bar.set_completion(completion)


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
