class_name BeddyBearBoss
extends BossBase

signal jump_slam_requested(damage: int)
signal triple_slam_requested(damage: int, hit_index: int)
signal block_requested

@export var cycles_before_special: int = 3

var _cycle_step: int = 0
var _completed_cycles: int = 0


func choose_next_move() -> BossMove:
	if moves.is_empty():
		return super.choose_next_move()

	if _completed_cycles >= cycles_before_special and moves.size() >= 3:
		_completed_cycles = 0
		_cycle_step = 0
		return moves[2]

	var next_move := moves[_cycle_step]
	_cycle_step += 1
	if _cycle_step >= mini(2, moves.size()):
		_cycle_step = 0
		_completed_cycles += 1
	return next_move


func execute_attack(move: AttackMove) -> void:
	if move.move_id == &"triple_slam":
		return
	if move.move_id == &"jump_slam":
		if is_dead or not is_instance_valid(target) or target.is_dead:
			return

		move_executed.emit(move)
		await get_tree().create_timer(0.57).timeout
		if is_dead or not is_instance_valid(target) or target.is_dead:
			return

		print("Beddy Bear jump slam impact.")
		deal_damage_to_target(move.damage)
		jump_slam_requested.emit(move.damage)
		return

	super.execute_attack(move)


func execute_triple_slam(move: TripleSlamMove) -> void:
	if is_dead or not is_instance_valid(target) or target.is_dead:
		return

	move_executed.emit(move)
	for hit_index in move.hit_count:
		await get_tree().create_timer(move.hit_interval).timeout
		if is_dead or not is_instance_valid(target) or target.is_dead:
			return

		print("Beddy Bear triple slam hit %d/%d." % [hit_index + 1, move.hit_count])
		deal_damage_to_target(move.damage)
		triple_slam_requested.emit(move.damage, hit_index)


func start_defending(duration: float, defense_damage: float = 0.0) -> void:
	super.start_defending(duration, defense_damage)
	block_requested.emit()
