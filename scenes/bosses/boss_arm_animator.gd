class_name BossArmAnimator
extends Node

@export var boss: BossBase
@export var left_arm: Sprite2D
@export var right_arm: Sprite2D

var _left_arm_rest_rotation: float
var _right_arm_rest_rotation: float
var _arm_tween: Tween


func _ready() -> void:
	_left_arm_rest_rotation = left_arm.rotation
	_right_arm_rest_rotation = right_arm.rotation

	boss.move_started.connect(_on_move_started)
	boss.move_executed.connect(_on_move_executed)


func _on_move_started(move: BossMove) -> void:
	if move.move_id == &"special_attack":
		_wind_up_special()


func _on_move_executed(move: BossMove) -> void:
	match move.move_id:
		&"base_attack":
			_swing_left_arm()
		&"special_attack":
			_swing_both_arms()


func _wind_up_special() -> void:
	_tween_arms(
		_left_arm_rest_rotation - deg_to_rad(55.0),
		_right_arm_rest_rotation + deg_to_rad(55.0),
		0.35
	)


func _swing_left_arm() -> void:
	_tween_arms(
		_left_arm_rest_rotation + deg_to_rad(100.0),
		right_arm.rotation,
		0.18
	)
	_arm_tween.set_parallel(false)
	_arm_tween.tween_property(left_arm, "rotation", _left_arm_rest_rotation, 0.22)


func _swing_both_arms() -> void:
	_tween_arms(
		_left_arm_rest_rotation + deg_to_rad(115.0),
		_right_arm_rest_rotation - deg_to_rad(115.0),
		0.2
	)
	_arm_tween.set_parallel(false)
	_arm_tween.tween_property(left_arm, "rotation", _left_arm_rest_rotation, 0.25)
	_arm_tween.set_parallel()
	_arm_tween.parallel().tween_property(right_arm, "rotation", _right_arm_rest_rotation, 0.25)


func _tween_arms(left_rotation: float, right_rotation: float, duration: float) -> void:
	if _arm_tween != null:
		_arm_tween.kill()

	_arm_tween = create_tween()
	_arm_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_arm_tween.tween_property(left_arm, "rotation", left_rotation, duration)
	_arm_tween.parallel().tween_property(right_arm, "rotation", right_rotation, duration)
