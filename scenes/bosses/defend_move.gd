class_name DefendMove
extends BossMove

@export var defense_duration: float = 1.0


func execute(boss: BossBase) -> void:
	boss.start_defending(defense_duration)