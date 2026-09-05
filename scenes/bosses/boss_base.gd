class_name BossBase
extends Node2D

signal move_started(move: BossMove)
signal move_executed(move: BossMove)
signal move_finished(move: BossMove)

@export var health: int = 100
@export var moves: Array[BossMove] = []
@export var target: Node
@export var animation_player: AnimationPlayer

var _current_move: BossMove
var _move_timer: float = 0.0
var _is_winding_up: bool = false


func _ready() -> void:
	move_started.connect(_on_move_started)
	move_executed.connect(_on_move_executed)
	move_finished.connect(_on_move_finished)


func _process(delta: float) -> void:
	if _move_timer > 0.0:
		_move_timer = maxf(0.0, _move_timer - delta)
		return

	if _current_move == null:
		_start_next_move()
		return

	if _is_winding_up:
		_is_winding_up = false
		_execute_current_move()


func choose_next_move() -> BossMove:
	if moves.is_empty():
		return null

	return moves[0]


func perform_move(move: BossMove) -> void:
	move_executed.emit(move)
	deal_damage_to_target(move.damage)


func deal_damage_to_target(amount: int) -> void:
	if amount <= 0 or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		target.call("take_damage", amount)


func _start_next_move() -> void:
	_current_move = choose_next_move()

	if _current_move == null:
		_move_timer = 0.1
		return

	print("Boss selected move: %s" % _current_move.move_id)
	move_started.emit(_current_move)

	if _current_move.windup > 0.0:
		_is_winding_up = true
		_move_timer = _current_move.windup
		print("Boss charging %s for %.2f seconds" % [
			_current_move.move_id,
			_current_move.windup
		])
	else:
		_execute_current_move()


func _execute_current_move() -> void:
	var move := _current_move
	_current_move = null
	print("Boss executed move: %s (damage: %d)" % [move.move_id, move.damage])
	move.execute(self)
	move_finished.emit(move)
	_move_timer = move.cooldown
	print("Boss cooldown for %s: %.2f seconds" % [move.move_id, move.cooldown])


func _on_move_started(move: BossMove) -> void:
	if move.windup <= 0.0:
		return

	_play_animation(&"%s_windup" % move.move_id)


func _on_move_executed(move: BossMove) -> void:
	_play_animation(move.move_id)


func _on_move_finished(_move: BossMove) -> void:
	_play_animation(&"idle")


func _play_animation(animation_name: StringName) -> void:
	if animation_player == null or not animation_player.has_animation(animation_name):
		return

	animation_player.play(animation_name)