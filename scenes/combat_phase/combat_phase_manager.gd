class_name CombatPhaseManager
extends Node2D

@export var boss_container: Node
@export var boss_spawn_position: Vector2 = Vector2.ZERO

var current_boss: Node

func initialize(boss_scene: PackedScene) -> Error:
	if boss_scene == null:
		return ERR_INVALID_PARAMETER

	var boss := boss_scene.instantiate()
	if boss == null:
		return ERR_CANT_CREATE

	_clear_current_boss()
	var spawn_parent := boss_container if is_instance_valid(boss_container) else self
	spawn_parent.add_child(boss)
	var boss_node_2d := boss as Node2D
	if boss_node_2d != null:
		boss_node_2d.position = boss_spawn_position

	current_boss = boss
	return OK


func get_current_boss() -> Node:
	return current_boss


func clear_boss() -> void:
	_clear_current_boss()


func _clear_current_boss() -> void:
	if is_instance_valid(current_boss):
		var parent := current_boss.get_parent()
		if parent != null:
			parent.remove_child(current_boss)
		current_boss.queue_free()
	current_boss = null
