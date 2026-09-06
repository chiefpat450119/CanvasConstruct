class_name DrawingUIAnim
extends Node

signal animation_started(backwards: bool)
signal animation_finished(backwards: bool)

enum SlideDirection {
	TOP,
	LEFT,
	RIGHT,
	BOTTOM,
}

@export_group("Components")
@export var phase_banner: Control
@export var timer: Control
@export var drawing_grid: Control
@export var reference_art: Control
@export var finish_button: Control

@export_group("Animation")
@export var play_on_ready := true
@export_range(0.05, 2.0, 0.01, "suffix:s") var component_duration := 0.4
@export_range(0.0, 1.0, 0.01, "suffix:s") var stagger := 0.07
@export_range(0.0, 256.0, 1.0, "suffix:px") var offscreen_margin := 32.0

var _components: Array[Control] = []
var _directions: Array[int] = []
var _rest_positions: Array[Vector2] = []
var _rest_modulates: Array[Color] = []
var _offscreen_offsets: Array[Vector2] = []
var _timeline := 1.0
var _active_tween: Tween


func _ready() -> void:
	_cache_components()
	if _components.is_empty():
		push_warning("DrawingUIAnim has no components to animate.")
		return

	if play_on_ready:
		_set_timeline(0.0)
		call_deferred(&"play_forward")
	else:
		_set_timeline(1.0)


func play(backwards := false) -> void:
	var target := 0.0 if backwards else 1.0
	_kill_active_tween()
	animation_started.emit(backwards)

	if is_equal_approx(_timeline, target):
		_set_timeline(target)
		animation_finished.emit(backwards)
		return

	var tween := create_tween()
	_active_tween = tween
	var duration := _get_total_duration() * absf(target - _timeline)
	tween.tween_method(_set_timeline, _timeline, target, duration)
	tween.tween_callback(_on_tween_finished.bind(tween, backwards))


func play_forward() -> void:
	play(false)


func play_reverse() -> void:
	play(true)


func restart() -> void:
	_kill_active_tween()
	_cache_rest_state()
	_set_timeline(0.0)
	play_forward()


func skip_to_start() -> void:
	_kill_active_tween()
	_set_timeline(0.0)


func skip_to_end() -> void:
	_kill_active_tween()
	_set_timeline(1.0)


func is_playing() -> bool:
	return _active_tween != null and _active_tween.is_valid()


func _cache_components() -> void:
	_add_component(phase_banner, SlideDirection.TOP)
	_add_component(timer, SlideDirection.TOP)
	_add_component(drawing_grid, SlideDirection.LEFT)
	_add_component(reference_art, SlideDirection.RIGHT)
	_add_component(finish_button, SlideDirection.BOTTOM)

	_cache_rest_state()


func _cache_rest_state() -> void:
	_rest_positions.clear()
	_rest_modulates.clear()
	_offscreen_offsets.clear()

	var screen_size := _get_screen_size()
	for index in range(_components.size()):
		var component := _components[index]
		_rest_positions.append(component.position)
		_rest_modulates.append(component.modulate)
		_offscreen_offsets.append(
			_get_offscreen_offset(component, _directions[index], screen_size)
		)


func _add_component(component: Control, direction: int) -> void:
	if component == null:
		return
	_components.append(component)
	_directions.append(direction)


func _set_timeline(value: float) -> void:
	_timeline = clampf(value, 0.0, 1.0)
	var elapsed := _timeline * _get_total_duration()

	for index in range(_components.size()):
		var component_progress := clampf(
			(elapsed - stagger * index) / component_duration,
			0.0,
			1.0
		)
		var movement_progress := _ease_out_cubic(component_progress)
		var fade_progress := _smoothstep(component_progress)
		var component := _components[index]

		component.position = (
			_rest_positions[index]
			+ _offscreen_offsets[index] * (1.0 - movement_progress)
		)
		var color := _rest_modulates[index]
		color.a *= fade_progress
		component.modulate = color


func _get_total_duration() -> float:
	return component_duration + stagger * maxi(_components.size() - 1, 0)


func _get_screen_size() -> Vector2:
	var parent_control := get_parent() as Control
	if parent_control != null and parent_control.size.x > 0.0 and parent_control.size.y > 0.0:
		return parent_control.size
	return get_viewport().get_visible_rect().size


func _get_offscreen_offset(
	component: Control,
	direction: int,
	screen_size: Vector2
) -> Vector2:
	match direction:
		SlideDirection.TOP:
			return Vector2(0.0, -component.position.y - component.size.y - offscreen_margin)
		SlideDirection.LEFT:
			return Vector2(-component.position.x - component.size.x - offscreen_margin, 0.0)
		SlideDirection.RIGHT:
			return Vector2(screen_size.x - component.position.x + offscreen_margin, 0.0)
		SlideDirection.BOTTOM:
			return Vector2(0.0, screen_size.y - component.position.y + offscreen_margin)

	return Vector2.ZERO


func _ease_out_cubic(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)


func _smoothstep(value: float) -> float:
	return value * value * (3.0 - 2.0 * value)


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _on_tween_finished(tween: Tween, backwards: bool) -> void:
	if tween != _active_tween:
		return
	_active_tween = null
	animation_finished.emit(backwards)
