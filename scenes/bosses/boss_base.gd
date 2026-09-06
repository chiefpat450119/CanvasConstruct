class_name BossBase
extends Node2D

signal move_started(move: BossMove)
signal move_executed(move: BossMove)
signal move_finished(move: BossMove)
signal defense_started(duration: float)
signal defense_finished
signal health_changed(current: int, maximum: int)
signal died

@export var health: int = 100
@export var moves: Array[BossMove] = []

var target: Player
var _max_health: int
var is_dead := false

var _current_move: BossMove
var _move_timer: float = 0.0
var _is_winding_up: bool = false
var _defense_timer: float = 0.0

var is_defending: bool:
	get:
		return _defense_timer > 0.0


func _ready() -> void:
	_max_health = health
	health_changed.emit(health, _max_health)


func set_target(player: Player) -> void:
	target = player

func _process(delta: float) -> void:
	if is_dead or not is_instance_valid(target) or target.is_dead:
		_current_move = null
		_move_timer = 0.0
		_is_winding_up = false
		return

	if _defense_timer > 0.0:
		_defense_timer = maxf(0.0, _defense_timer - delta)
		if _defense_timer == 0.0:
			defense_finished.emit()

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


func execute_attack(move: AttackMove) -> void:
	if is_dead or not is_instance_valid(target) or target.is_dead:
		return

	move_executed.emit(move)
	deal_damage_to_target(move.damage)


func start_defending(duration: float) -> void:
	if is_dead:
		return

	_defense_timer = maxf(0.0, duration)
	defense_started.emit(_defense_timer)


func deal_damage_to_target(amount: int) -> void:
	if amount <= 0 or not is_instance_valid(target) or target.is_dead:
		push_warning("BossBase: No valid target to deal damage to.")
		return

	target.take_damage(amount)


func take_damage(amount: float) -> void:
	if amount <= 0.0 or health <= 0:
		return

	health = maxi(0, health - roundi(amount))
	health_changed.emit(health, _max_health)
	if health == 0 and not is_dead:
		is_dead = true
		_current_move = null
		_move_timer = 0.0
		_is_winding_up = false
		_defense_timer = 0.0
		print("Boss died.")
		died.emit()


func _start_next_move() -> void:
	_current_move = choose_next_move()

	if _current_move == null:
		_move_timer = _current_move.cooldown
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
	print("Boss executed move: %s" % move.move_id)
	move.execute(self)
	move_finished.emit(move)
	_move_timer = move.cooldown
	print("Boss cooldown for %s: %.2f seconds" % [move.move_id, move.cooldown])
