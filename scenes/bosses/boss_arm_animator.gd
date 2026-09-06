class_name BossArmAnimator
extends Node

@export var boss: BossBase
@export var left_arm: Sprite2D
@export var right_arm: Sprite2D
@export var animation_player : AnimationPlayer
@export var charge_particles : CPUParticles2D
@export var swing_VFX : AnimatedSprite2D

var _left_arm_rest_rotation: float
var _right_arm_rest_rotation: float
var _arm_tween: Tween


func _ready() -> void:
	_left_arm_rest_rotation = left_arm.rotation
	_right_arm_rest_rotation = right_arm.rotation

	boss.move_started.connect(_on_move_started)
	boss.move_executed.connect(_on_move_executed)
	animation_player.play("orc_idle")


func _on_move_started(move: BossMove) -> void:
	charge_particles.emitting = true
	if move.move_id == &"special_attack":
		_wind_up_special()
	if move.move_id == &"base_attack":
		_wind_up_base_attack()


func _on_move_executed(move: BossMove) -> void:
	charge_particles.emitting = false
	swing_VFX.play()
	match move.move_id:
		&"base_attack":
			_swing_left_arm()
		&"special_attack":
			_swing_both_arms()


func _wind_up_special() -> void:
	animation_player.play("orc_lift_axe_special")

func _wind_up_base_attack() -> void:
	animation_player.play("orc_lift_axe")

func _swing_left_arm() -> void:
	animation_player.play("orc_swing_axe")
	animation_player.queue("orc_idle")


func _swing_both_arms() -> void:
	animation_player.play("orc_swing_axe_special")
	animation_player.queue("orc_idle")


func _tween_arms(left_rotation: float, right_rotation: float, duration: float) -> void:
	if _arm_tween != null:
		_arm_tween.kill()

	_arm_tween = create_tween()
	_arm_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_arm_tween.tween_property(left_arm, "rotation", left_rotation, duration)
	_arm_tween.parallel().tween_property(right_arm, "rotation", right_rotation, duration)
