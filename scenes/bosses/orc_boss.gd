class_name FirstBoss
extends BossBase

signal base_attack_requested(damage: int)
signal special_attack_requested(damage: int)

@export var attacks_before_special: int = 3

var _attacks_in_cycle: int = 0


func _ready() -> void:
	super._ready()


func choose_next_move() -> BossMove:
	if moves.is_empty():
		return super.choose_next_move()
	if moves.size() == 1:
		return moves[0]

	if _attacks_in_cycle < attacks_before_special:
		_attacks_in_cycle += 1
		return moves[0]

	_attacks_in_cycle = 0
	return moves[1]


func execute_attack(move: AttackMove) -> void:
	super.execute_attack(move)

	match move.move_id:
		&"base_attack":
			base_attack_requested.emit(move.damage)
		&"special_attack":
			special_attack_requested.emit(move.damage)