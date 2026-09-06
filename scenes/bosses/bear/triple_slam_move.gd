class_name TripleSlamMove
extends BossMove

@export var damage: int = 0
@export var hit_count: int = 3
@export var hit_interval: float = 0.25


func execute(boss: BossBase) -> void:
	boss.execute_triple_slam(self)
