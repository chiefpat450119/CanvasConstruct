class_name TotalProgressBar
extends Control

@export var progress_bar: ProgressBar
@export var percentage_label: Label


func set_completion(completion: float) -> void:
	var percentage := roundi(clampf(completion, 0.0, 1.0) * 100.0)

	if progress_bar != null:
		progress_bar.value = percentage
	if percentage_label != null:
		percentage_label.text = "%d%%" % percentage
