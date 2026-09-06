extends CanvasLayer

signal finished

@export_range(0.0, 2.0, 0.05) var half_duration: float = 0.4
@onready var transition_material := $ColorRect.material as ShaderMaterial

var _active_tween: Tween

func _ready() -> void:
	_set_progress(0.0)
	hide()


func start() -> void:
	_kill_active_tween()
	_set_progress(0.0)
	show()

	var tween := create_tween()
	_active_tween = tween
	var progress_tweener := tween.tween_method(
		_set_progress,
		0.0,
		0.5,
		half_duration
	)
	progress_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	if _active_tween == tween:
		_active_tween = null


func finish() -> void:
	_kill_active_tween()
	_set_progress(0.5)
	show()

	var tween := create_tween()
	_active_tween = tween
	var progress_tweener := tween.tween_method(
		_set_progress,
		0.5,
		1.0,
		half_duration
	)
	progress_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_finish_completed.bind(tween))


func _set_progress(value: float) -> void:
	transition_material.set_shader_parameter(&"progress", value)


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _on_finish_completed(tween: Tween) -> void:
	if _active_tween != tween:
		return

	_active_tween = null
	hide()
	_set_progress(0.0)
	finished.emit()
