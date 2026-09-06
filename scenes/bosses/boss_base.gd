class_name BossBase
extends Node2D

signal move_started(move: BossMove)
signal move_executed(move: BossMove)
signal move_finished(move: BossMove)

@export var health: int = 100
@export var moves: Array[BossMove] = []
@export var target: Node

var _current_move: BossMove
var _move_timer: float = 0.0
var _is_winding_up: bool = false


func _ready() -> void:
	pass


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

# Base behaviour: just choose the first move in the list. Should be overriden by subclasses
func choose_next_move() -> BossMove:
	if moves.is_empty():
		return null

	return moves[0]


func perform_move(move: BossMove) -> void:
	move_executed.emit(move)
	deal_damage_to_target(move.damage)


func deal_damage_to_target(amount: int) -> void:
	if amount <= 0 or not is_instance_valid(target):
		push_warning("BossBase: No valid target to deal damage to.")
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
