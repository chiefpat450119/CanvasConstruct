class_name AttackMove
extends BossMove

@export var damage: int = 0


func execute(boss: BossBase) -> void:
	boss.execute_attack(self)