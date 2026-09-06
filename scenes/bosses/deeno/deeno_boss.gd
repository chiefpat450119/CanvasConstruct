class_name DeenoBoss
extends BossBase

signal chomp_requested(damage: int)
signal block_requested
signal special_attack_requested(damage: int)

@export var cycles_before_special: int = 3

var _cycle_step: int = 0
var _completed_cycles: int = 0
@onready var _body: Sprite2D = $Body
var _body_rest_scale: Vector2


func _ready() -> void:
	super._ready()
	_body_rest_scale = _body.scale
	defense_finished.connect(_on_defense_finished)


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
	super.execute_attack(move)

	match move.move_id:
		&"chomp":
			chomp_requested.emit(move.damage)
		&"special_attack":
			special_attack_requested.emit(move.damage)


func start_defending(duration: float, defense_damage: float = 0.0) -> void:
	super.start_defending(duration, defense_damage)
	_body.scale.x = -_body_rest_scale.x
	block_requested.emit()


func _on_defense_finished() -> void:
	_body.scale = _body_rest_scale


