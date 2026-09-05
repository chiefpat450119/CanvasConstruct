@tool
class_name HeadResource
extends PartResource

@export_group("Stats")
@export_range(0.0, 60.0, 0.01, "or_greater", "suffix:s")
var cooldown_seconds: float = 1.0
