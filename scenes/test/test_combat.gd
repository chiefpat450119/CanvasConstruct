extends Node2D

const ORC_BOSS_SCENE := preload("res://scenes/bosses/orc_boss.tscn")


func _ready() -> void:
	$CombatPhase.initialize(ORC_BOSS_SCENE)