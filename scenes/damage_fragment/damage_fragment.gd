class_name DamageFragment
extends Node2D

@export_range(0.0, 2000.0, 10.0, "or_greater") var gravity: float = 850.0
@export_range(0.1, 10.0, 0.1, "or_greater") var lifetime: float = 1.5
@export_range(0.0, 10.0, 0.05, "or_greater") var fade_duration: float = 0.35

@export var fragment_sprite: Sprite2D

var _velocity := Vector2.ZERO
var _angular_velocity := 0.0
var _age := 0.0


func initialize(texture: Texture2D, outward_direction: float) -> void:
	fragment_sprite.texture = texture
	_velocity = Vector2(
		outward_direction * randf_range(45.0, 80.0) + randf_range(-15.0, 15.0),
		randf_range(-125.0, -80.0)
	)
	_angular_velocity = randf_range(-4.0, 4.0)


func _process(delta: float) -> void:
	_age += delta
	_velocity.y += gravity * delta
	global_position += _velocity * delta
	global_rotation += _angular_velocity * delta

	var fade_start := maxf(0.0, lifetime - fade_duration)
	if _age > fade_start and fade_duration > 0.0:
		modulate.a = clampf((lifetime - _age) / fade_duration, 0.0, 1.0)

	if _age >= lifetime:
		queue_free()
