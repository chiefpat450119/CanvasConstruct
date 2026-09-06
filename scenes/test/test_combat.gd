extends Node2D

@export var boss_scene: PackedScene

@export var head_part: HeadResource
@export var weapon_part: AtkResource
@export var defense_part: DefResource
@export var torso_part: TorsoResource


func _ready() -> void:
	var player_parts: Array[PlayerPart] = [
		PlayerPart.new(head_part, head_part.reference_image.get_image()),
		PlayerPart.new(weapon_part, weapon_part.reference_image.get_image()),
		PlayerPart.new(defense_part, defense_part.reference_image.get_image()),
		PlayerPart.new(torso_part, torso_part.reference_image.get_image()),
	]
	$CombatPhase.initialize(boss_scene, player_parts)
