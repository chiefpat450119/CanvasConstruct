class_name FirstBoss
extends BossBase

signal base_attack_requested(damage: int)
signal special_attack_requested(damage: int)

@export var base_attack_damage: int = 10
@export var special_attack_damage: int = 40
@export var attacks_before_special: int = 3
@export var base_attack_cooldown: float = 0.75
@export var special_windup: float = 4.0
@export var special_cooldown: float = 1.0

var base_attack: BossMove
var special_attack: BossMove
var _attacks_in_cycle: int = 0


func _ready() -> void:
	base_attack = BossMove.new(
		&"base_attack",
		base_attack_cooldown,
		0.0,
		base_attack_damage
	)
	special_attack = BossMove.new(
		&"special_attack",
		special_cooldown,
		special_windup,
		special_attack_damage
	)

	moves = [base_attack, special_attack]
	super._ready()


func choose_next_move() -> BossMove:
	if _attacks_in_cycle < attacks_before_special:
		_attacks_in_cycle += 1
		return base_attack

	_attacks_in_cycle = 0
	return special_attack


func perform_move(move: BossMove) -> void:
	super.perform_move(move)

	match move.move_id:
		&"base_attack":
			base_attack_requested.emit(move.damage)
		&"special_attack":
			special_attack_requested.emit(move.damage)