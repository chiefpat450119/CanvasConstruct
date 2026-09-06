class_name PlayerAnimations
extends Node

@export var player: Player
@export var torso: Node2D
@export var head: Node2D
@export var weapon: Node2D
@export var shield: Node2D

@export_group("Idle Animation")
@export_range(0.0, 10.0, 0.1, "or_greater") var bob_distance := 1.5
@export_range(0.1, 10.0, 0.1, "or_greater") var torso_bob_duration := 2.4
@export_range(0.1, 10.0, 0.1, "or_greater") var head_bob_duration := 2.1
@export_range(0.1, 10.0, 0.1, "or_greater") var weapon_bob_duration := 1.8
@export_range(0.1, 10.0, 0.1, "or_greater") var shield_bob_duration := 2.0

var _torso_rest_position: Vector2
var _head_rest_position: Vector2
var _weapon_rest_position: Vector2
var _shield_rest_position: Vector2
var _weapon_action_offset := Vector2.ZERO
var _shield_action_offset := Vector2.ZERO
var _idle_time := 0.0


func _ready() -> void:
	_torso_rest_position = torso.position
	_head_rest_position = head.position
	_weapon_rest_position = weapon.position
	_shield_rest_position = shield.position
	player.action_started.connect(_on_player_action_started)


func _process(delta: float) -> void:
	_idle_time += delta
	torso.position = _torso_rest_position + _get_bob_offset(torso_bob_duration)
	head.position = _head_rest_position + _get_bob_offset(head_bob_duration)
	weapon.position = _weapon_rest_position + _get_bob_offset(weapon_bob_duration) + _weapon_action_offset
	shield.position = _shield_rest_position + _get_bob_offset(shield_bob_duration) + _shield_action_offset


func _on_player_action_started(action: StringName) -> void:
	match action:
		&"attack":
			_play_attack()
		&"defend":
			_play_defend()


func _play_attack() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_weapon_action_offset", Vector2(18.0, 0.0), 0.12)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "_weapon_action_offset", Vector2.ZERO, 0.16)


func _play_defend() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_shield_action_offset", Vector2(10.0, -12.0), 0.12)
	tween.tween_interval(Player.DEFENSE_DURATION)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "_shield_action_offset", Vector2.ZERO, 0.16)


func _get_bob_offset(duration: float) -> Vector2:
	return Vector2(0.0, sin(_idle_time * TAU / duration) * bob_distance)
