class_name CombatPhaseManager
extends Node2D

@export var boss_container: Node
@export var boss_spawn_position: Vector2 = Vector2.ZERO
@export var player: Player
@export var combat_ui: CombatUI

signal victory
signal defeat

var current_boss: Node

func _ready() -> void:
	if player != null:
		player.died.connect(_on_player_died)

	if combat_ui != null:
		combat_ui.attack_requested.connect(_on_attack_requested)
		combat_ui.defend_requested.connect(_on_defend_requested)

func initialize(boss_scene: PackedScene, player_parts: Array[PlayerPart] = []) -> Error:
	if boss_scene == null:
		return ERR_INVALID_PARAMETER
	if player_parts.size() != 4 or player == null:
		return ERR_INVALID_PARAMETER

	player.initialize_from_parts(
		player_parts[0],
		player_parts[1],
		player_parts[2],
		player_parts[3]
	)

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
	boss.died.connect(_on_boss_died)
	boss.set_target(player)
	if combat_ui != null:
		combat_ui.bind_combatant(player, boss)
	return OK


func get_current_boss() -> Node:
	return current_boss


func get_player_drawings() -> Array[Image]:
	if player == null:
		return []
	return player.get_part_drawings()


func clear_boss() -> void:
	_clear_current_boss()
	if combat_ui != null:
		combat_ui.clear_boss()


func _on_attack_requested() -> void:
	if is_instance_valid(current_boss) and player != null:
		player.attack(current_boss as BossBase)


func _on_defend_requested() -> void:
	if player != null:
		player.defend()


func _on_boss_died() -> void:
	victory.emit()


func _on_player_died() -> void:
	defeat.emit()


func _clear_current_boss() -> void:
	if is_instance_valid(current_boss):
		var parent := current_boss.get_parent()
		if parent != null:
			parent.remove_child(current_boss)
		current_boss.queue_free()
	current_boss = null
