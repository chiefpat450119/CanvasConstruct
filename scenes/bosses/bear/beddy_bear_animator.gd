class_name BeddyBearAnimator
extends Node

@export var boss: BossBase
@export var animation_player: AnimationPlayer
@export var charge_particles: CPUParticles2D
@export var hit_vfx: Array[Sprite2D] = []
@export var shield_vfx: Sprite2D


func _ready() -> void:
	boss.move_started.connect(_on_move_started)
	boss.move_executed.connect(_on_move_executed)
	boss.defense_finished.connect(_on_defense_finished)
	boss.connect(&"jump_slam_requested", _on_jump_slam_impact)
	boss.connect(&"triple_slam_requested", _on_triple_slam_impact)
	boss.connect(&"block_requested", _on_block_requested)
	animation_player.play(&"bear_idle")


func _on_move_started(move: BossMove) -> void:
	if move.windup <= 0.0:
		return

	print("Beddy Bear charging %s for %.2f seconds." % [move.move_id, move.windup])
	charge_particles.emitting = true
	animation_player.play(&"bear_charge")


func _on_move_executed(move: BossMove) -> void:
	if move.windup > 0.0:
		charge_particles.emitting = false

	match move.move_id:
		&"jump_slam":
			animation_player.play(&"bear_jump_slam")
		&"triple_slam":
			if animation_player.current_animation != &"bear_triple_slam":
				animation_player.play(&"bear_triple_slam")


func _on_block_requested() -> void:
	_play_shield_vfx()


func _on_jump_slam_impact(_damage: int) -> void:
	_play_hit_vfx()


func _on_triple_slam_impact(_damage: int, _hit_index: int) -> void:
	_play_hit_vfx()


func _play_hit_vfx() -> void:
	for hit_effect in hit_vfx:
		hit_effect.position = Vector2(
			randf_range(-34.0, 34.0),
			randf_range(38.0, 48.0)
		)
		hit_effect.visible = true
		hit_effect.frame = 0
		_advance_vfx(hit_effect, 4, 0.1)
	print("Beddy Bear hit VFX played.")


func _play_shield_vfx() -> void:
	shield_vfx.visible = true
	shield_vfx.frame = 0
	_advance_vfx(shield_vfx, 11, 0.1, true)


func _advance_vfx(vfx: Sprite2D, frame_count: int, frame_time: float, loop := false) -> void:
	while vfx.visible:
		await get_tree().create_timer(frame_time).timeout
		if not is_instance_valid(vfx):
			return
		var next_frame := vfx.frame + 1
		if next_frame >= frame_count:
			if loop:
				vfx.frame = 0
			else:
				vfx.visible = false
			return
		vfx.frame = next_frame


func _on_defense_finished() -> void:
	shield_vfx.visible = false
