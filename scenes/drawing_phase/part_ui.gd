class_name PartUI
extends Control

signal selected

@export var select_button: Button
@export var preview: Button
@export var similarity_label: Label
@export var description_bar: TextureRect
@export var icon: TextureRect
@export var lock: TextureRect


func _ready() -> void:
	if lock != null:
		lock.visible = false
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if select_button == null:
		push_error("PartUI needs a select button.")
		return

	select_button.pressed.connect(selected.emit)


func set_preview(texture: Texture2D) -> void:
	if preview == null:
		return

	preview.icon = texture
	preview.visible = texture != null


func set_similarity(similarity: float) -> void:
	if similarity_label == null:
		return

	similarity_label.text = "%d%%" % roundi(
		clampf(similarity, 0.0, 1.0) * 100.0
	)


func disable() -> void:
	if select_button != null:
		select_button.disabled = true
	_set_disabled_modulate(select_button)
	_set_disabled_modulate(description_bar)
	_set_disabled_modulate(icon)
	if lock != null:
		lock.visible = true


func _set_disabled_modulate(control: CanvasItem) -> void:
	if control != null:
		control.modulate = Color(0.5, 0.5, 0.5, 1.0)
