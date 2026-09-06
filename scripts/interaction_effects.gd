class_name InteractionEffects
extends Node

@export var target_control: Control
@export var center_pivot := true

@export_group("Hover")
@export var hover_scale := Vector2(1.06, 1.03)
@export_range(-45.0, 45.0, 0.1, "suffix:°") var hover_wobble_degrees := 2.5
@export_range(0.01, 2.0, 0.01, "suffix:s") var hover_duration := 0.22
@export_range(0.01, 2.0, 0.01, "suffix:s") var hover_exit_duration := 0.16

@export_group("Press")
@export var press_scale := Vector2(1.10, 0.90)
@export_range(-45.0, 45.0, 0.1, "suffix:°") var press_rotation_degrees := -2.0
@export_range(0.01, 2.0, 0.01, "suffix:s") var press_duration := 0.08

@export_group("Hold Shake")
@export var shake_while_pressed := true
@export_range(-45.0, 45.0, 0.1, "suffix:°") var shake_rotation_degrees := 3.0
@export_range(0.01, 2.0, 0.01, "suffix:s") var shake_half_cycle_duration := 0.10

@export_group("Release")
@export var release_scale := Vector2(0.95, 1.09)
@export_range(-45.0, 45.0, 0.1, "suffix:°") var release_rotation_degrees := 3.0
@export_range(0.01, 2.0, 0.01, "suffix:s") var release_duration := 0.10
@export_range(0.01, 2.0, 0.01, "suffix:s") var settle_duration := 0.20

@export_group("Tween")
@export var transition_type: Tween.TransitionType = Tween.TRANS_BACK
@export var ease_type: Tween.EaseType = Tween.EASE_OUT

var _base_scale: Vector2
var _base_rotation: float
var _active_tween: Tween
var _hold_shake_tween: Tween
var _hovered := false
var _pressed := false
var _uses_button_signals := false


func _ready() -> void:
	if target_control == null:
		push_error("InteractionEffects needs a target Control.")
		return

	_base_scale = target_control.scale
	_base_rotation = target_control.rotation

	if center_pivot:
		_center_target_pivot()
		target_control.resized.connect(_center_target_pivot)

	target_control.mouse_entered.connect(_on_mouse_entered)
	target_control.mouse_exited.connect(_on_mouse_exited)

	if target_control is BaseButton:
		_uses_button_signals = true
		var button := target_control as BaseButton
		button.button_down.connect(_on_pressed)
		button.button_up.connect(_on_released)
	else:
		target_control.gui_input.connect(_on_gui_input)

	set_process_input(false)


func _input(event: InputEvent) -> void:
	if not _pressed or _uses_button_signals:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_on_released()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if not touch_event.pressed:
			_on_released()


func _on_mouse_entered() -> void:
	_hovered = true
	if not _pressed:
		_play_hover()


func _on_mouse_exited() -> void:
	_hovered = false
	if not _pressed:
		_tween_to(Vector2.ONE, 0.0, hover_exit_duration)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_on_pressed()
		elif _pressed:
			_on_released()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_on_pressed()
		elif _pressed:
			_on_released()


func _on_pressed() -> void:
	if _pressed:
		return

	_pressed = true
	if not _uses_button_signals:
		set_process_input(true)
	_play_press()


func _on_released() -> void:
	if not _pressed:
		return

	_pressed = false
	set_process_input(false)
	_play_release()


func _play_hover() -> void:
	_kill_active_tween()
	_active_tween = create_tween()
	var hover_tweener := _active_tween.tween_method(
		_apply_hover.bind(target_control.scale, target_control.rotation),
		0.0,
		1.0,
		hover_duration
	)
	hover_tweener.set_trans(transition_type).set_ease(ease_type)


func _play_press() -> void:
	_kill_active_tween()
	_kill_hold_shake()
	_active_tween = create_tween()

	var scale_tweener := _active_tween.tween_property(
		target_control,
		"scale",
		_scaled(press_scale),
		press_duration
	)
	scale_tweener.set_trans(transition_type).set_ease(ease_type)

	if shake_while_pressed:
		_start_hold_shake()
	else:
		var rotation_tweener := _active_tween.parallel().tween_property(
			target_control,
			"rotation",
			_rotated(press_rotation_degrees),
			press_duration
		)
		rotation_tweener.set_trans(transition_type).set_ease(ease_type)


func _start_hold_shake() -> void:
	_hold_shake_tween = create_tween().set_loops()

	var shake_out := _hold_shake_tween.tween_property(
		target_control,
		"rotation",
		_rotated(press_rotation_degrees + shake_rotation_degrees),
		shake_half_cycle_duration
	)
	shake_out.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var shake_back := _hold_shake_tween.tween_property(
		target_control,
		"rotation",
		_rotated(press_rotation_degrees),
		shake_half_cycle_duration
	)
	shake_back.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_release() -> void:
	_kill_hold_shake()
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)

	var scale_pop := _active_tween.tween_property(
		target_control,
		"scale",
		_scaled(release_scale),
		release_duration
	)
	scale_pop.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	var rotation_pop := _active_tween.tween_property(
		target_control,
		"rotation",
		_rotated(release_rotation_degrees),
		release_duration
	)
	rotation_pop.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_active_tween.chain()
	var destination_scale := hover_scale if _hovered else Vector2.ONE
	var scale_settle := _active_tween.tween_property(
		target_control,
		"scale",
		_scaled(destination_scale),
		settle_duration
	)
	scale_settle.set_trans(transition_type).set_ease(ease_type)

	var rotation_settle := _active_tween.tween_property(
		target_control,
		"rotation",
		_base_rotation,
		settle_duration
	)
	rotation_settle.set_trans(transition_type).set_ease(ease_type)


func _apply_hover(
	progress: float,
	initial_scale: Vector2,
	initial_rotation: float
) -> void:
	var wobble_progress := clampf(progress, 0.0, 1.0)
	var damped_wobble := (
		sin(wobble_progress * TAU * 1.5)
		* (1.0 - wobble_progress)
		* deg_to_rad(hover_wobble_degrees)
	)
	target_control.scale = initial_scale.lerp(_scaled(hover_scale), progress)
	target_control.rotation = (
		lerp_angle(initial_rotation, _base_rotation, wobble_progress)
		+ damped_wobble
	)


func _tween_to(
	scale_multiplier: Vector2,
	rotation_degrees: float,
	duration: float
) -> void:
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)

	var scale_tweener := _active_tween.tween_property(
		target_control,
		"scale",
		_scaled(scale_multiplier),
		duration
	)
	scale_tweener.set_trans(transition_type).set_ease(ease_type)

	var rotation_tweener := _active_tween.tween_property(
		target_control,
		"rotation",
		_rotated(rotation_degrees),
		duration
	)
	rotation_tweener.set_trans(transition_type).set_ease(ease_type)


func _scaled(multiplier: Vector2) -> Vector2:
	return _base_scale * multiplier


func _rotated(degrees: float) -> float:
	return _base_rotation + deg_to_rad(degrees)


func _center_target_pivot() -> void:
	if target_control != null:
		target_control.pivot_offset = target_control.size * 0.5


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()


func _kill_hold_shake() -> void:
	if _hold_shake_tween != null and _hold_shake_tween.is_valid():
		_hold_shake_tween.kill()
	_hold_shake_tween = null
