class_name DeenoAnimator
extends Node

@export var boss: DeenoBoss
@export var animation_player : AnimationPlayer
@export var charge_particles : CPUParticles2D
@export var chomp_VFX : AnimatedSprite2D
@export var block_VFX : AnimatedSprite2D


func _ready() -> void:
	boss.move_started.connect(_on_move_started)
	boss.move_executed.connect(_on_move_executed)
	boss.block_requested.connect(_on_block_requested)
	boss.block_finished.connect(_on_block_finished)
	animation_player.play("deeno_idle")


func _on_move_started(move: BossMove) -> void:
	if move.move_id == &"special_attack":
		charge_particles.emitting = true
		_wind_up_big_chomp_attack()
	if move.move_id == &"chomp":
		charge_particles.emitting = true
		_wind_up_chomp_attack()


func _on_move_executed(move: BossMove) -> void:
	charge_particles.emitting = false
	chomp_VFX.play()
	match move.move_id:
		&"chomp":
			_chomp_attack()
		&"special_attack":
			_big_chomp_attack()

func _on_block_requested() -> void:
	block_VFX.visible = true

func _on_block_finished() -> void:
	block_VFX.visible = false

func _wind_up_big_chomp_attack() -> void:
	animation_player.play("deeno_jaw_open_special")

func _wind_up_chomp_attack() -> void:
	animation_player.play("deeno_jaw_open")

func _chomp_attack() -> void:
	animation_player.play("deeno_chomp")
	animation_player.queue("deeno_idle")

func _big_chomp_attack() -> void:
	animation_player.play("deeno_chomp_special")
	animation_player.queue("deeno_idle")
