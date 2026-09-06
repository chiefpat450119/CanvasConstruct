class_name DrawingPhaseManager
extends Node

enum PartCategory {
	HEAD,
	ATK,
	DEF,
	TORSO,
}

signal phase_completed

const PART_CATEGORIES: Array[PartCategory] = [
	PartCategory.HEAD,
	PartCategory.ATK,
	PartCategory.DEF,
	PartCategory.TORSO,
]

@export var drawing_ui: DrawingUI
@export var selection_screen: CanvasItem

@export_group("Drawing Times")
@export_range(0.1, 120.0, 0.1, "or_greater", "suffix:s")
var head_drawing_seconds: float = 5.0
@export_range(0.1, 120.0, 0.1, "or_greater", "suffix:s")
var atk_drawing_seconds: float = 5.0
@export_range(0.1, 120.0, 0.1, "or_greater", "suffix:s")
var def_drawing_seconds: float = 5.0
@export_range(0.1, 120.0, 0.1, "or_greater", "suffix:s")
var torso_drawing_seconds: float = 8.0

var _current_parts: Dictionary[PartCategory, PartResource] = {}
var _available_upgrades: Dictionary[PartCategory, PartResource] = {}
var _completed_categories: Dictionary[PartCategory, bool] = {}
var _active_reference_part: PartResource
var _drawing_timer: Timer
var _phase_active: bool = false


func _ready() -> void:
	_ensure_timer()
	_set_drawing_screen_active(false)


func begin_phase(
	current_parts: Array[PartResource],
	available_upgrades: Array[PartResource] = []
) -> void:
	if _phase_active:
		return

	_current_parts = _map_parts_by_category(current_parts)
	_available_upgrades = _map_parts_by_category(available_upgrades)
	_completed_categories.clear()
	_phase_active = true
	_set_drawing_screen_active(false)


func start_repair(reference_part: PartResource) -> void:
	if can_repair(reference_part):
		_start_part_drawing(reference_part)


func start_upgrade(reference_part: PartResource) -> void:
	if can_upgrade(reference_part):
		_start_part_drawing(reference_part)


func can_repair(reference_part: PartResource) -> bool:
	if not _can_start_part(reference_part):
		return false
	if not GameStateManagerInstance.can_repair_parts():
		return false

	var category := _get_part_category(reference_part)
	return _current_parts.get(category) == reference_part


func can_upgrade(reference_part: PartResource) -> bool:
	if not _can_start_part(reference_part):
		return false

	var category := _get_part_category(reference_part)
	return _available_upgrades.get(category) == reference_part


func get_current_parts() -> Array[PartResource]:
	var parts: Array[PartResource] = []
	for category: PartCategory in PART_CATEGORIES:
		var part := _current_parts.get(category) as PartResource
		parts.append(part)
	return parts


func get_available_upgrade(current_part: PartResource) -> PartResource:
	var category := _get_part_category(current_part)
	if category < 0 or _current_parts.get(category) != current_part:
		return null
	return _available_upgrades.get(category) as PartResource


func get_remaining_parts() -> Array[PartResource]:
	var parts: Array[PartResource] = []
	for category: PartCategory in PART_CATEGORIES:
		if not _completed_categories.has(category):
			var part := _current_parts.get(category) as PartResource
			parts.append(part)
	return parts


func is_part_completed(part: PartResource) -> bool:
	var category := _get_part_category(part)
	return category >= 0 and _completed_categories.has(category)


func is_phase_active() -> bool:
	return _phase_active


func is_drawing_part() -> bool:
	return _active_reference_part != null


func can_leave_current_drawing() -> bool:
	return not is_drawing_part()


func get_active_drawing_grid() -> DrawingGrid:
	if not is_drawing_part():
		return null
	return drawing_ui.get_drawing_grid()


func get_active_reference_part() -> PartResource:
	return _active_reference_part


func get_active_reference_image() -> Texture2D:
	if _active_reference_part == null:
		return null
	return _active_reference_part.reference_image


func get_drawing_time_left() -> float:
	if _drawing_timer.is_stopped():
		return 0.0
	return _drawing_timer.time_left


func _start_part_drawing(reference_part: PartResource) -> void:
	var reference_image := reference_part.reference_image
	var category := _get_part_category(reference_part)
	var duration := _get_drawing_duration(category)
	_ensure_timer()
	_drawing_timer.start(duration)
	_set_drawing_screen_active(true)
	drawing_ui.setup_drawing(reference_image, _drawing_timer)
	_active_reference_part = reference_part


func _complete_part_drawing() -> void:
	if not is_drawing_part():
		return

	var category := _get_part_category(_active_reference_part)

	_completed_categories[category] = true
	var finishes_phase := _completed_categories.size() == PART_CATEGORIES.size()
	if finishes_phase:
		_phase_active = false
		GameStateManagerInstance.mark_drawing_phase_completed()

	_active_reference_part = null
	drawing_ui.stop_drawing()
	_set_drawing_screen_active(false)

	if finishes_phase:
		phase_completed.emit()


func _can_start_part(reference_part: PartResource) -> bool:
	if not _phase_active or is_drawing_part() or reference_part == null:
		return false

	var category := _get_part_category(reference_part)
	return category >= 0 and not _completed_categories.has(category)


func _ensure_timer() -> void:
	if _drawing_timer != null:
		return
	_drawing_timer = Timer.new()
	_drawing_timer.one_shot = true
	_drawing_timer.timeout.connect(_complete_part_drawing)
	add_child(_drawing_timer)


func _set_drawing_screen_active(is_active: bool) -> void:
	_set_screen_enabled(drawing_ui, is_active)
	if selection_screen != null:
		_set_screen_enabled(selection_screen, not is_active)


func _set_screen_enabled(screen: CanvasItem, is_enabled: bool) -> void:
	screen.visible = is_enabled
	screen.process_mode = (
		Node.PROCESS_MODE_INHERIT if is_enabled else Node.PROCESS_MODE_DISABLED
	)


func _map_parts_by_category(
	parts: Array[PartResource]
) -> Dictionary[PartCategory, PartResource]:
	var parts_by_category: Dictionary[PartCategory, PartResource] = {}
	for part: PartResource in parts:
		if part != null:
			parts_by_category[_get_part_category(part)] = part
	return parts_by_category


func _get_part_category(part: PartResource) -> PartCategory:
	if part is HeadResource:
		return PartCategory.HEAD
	if part is AtkResource:
		return PartCategory.ATK
	if part is DefResource:
		return PartCategory.DEF
	if part is TorsoResource:
		return PartCategory.TORSO
	return -1


func _get_drawing_duration(category: PartCategory) -> float:
	match category:
		PartCategory.HEAD:
			return head_drawing_seconds
		PartCategory.ATK:
			return atk_drawing_seconds
		PartCategory.DEF:
			return def_drawing_seconds
		PartCategory.TORSO:
			return torso_drawing_seconds
	return 0.0
