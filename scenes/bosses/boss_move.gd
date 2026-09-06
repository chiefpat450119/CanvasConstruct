class_name BossMove
extends Resource

@export var move_id: StringName
@export var cooldown: float = 1.0
@export var windup: float = 0.0


func _init(id: StringName = &"", move_cooldown: float = 1.0, move_windup: float = 0.0) -> void:
	move_id = id
	cooldown = move_cooldown
	windup = move_windup