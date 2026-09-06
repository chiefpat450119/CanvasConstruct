class_name DefendMove
extends BossMove

@export var defense_duration: float = 1.0
@export var thorns_damage: float = 0.0


func execute(boss: BossBase) -> void:
	print("Executing defend move: %s" % move_id)
	boss.start_defending(defense_duration, thorns_damage)
