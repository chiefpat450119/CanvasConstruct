class_name PartUI
extends Control

signal selected

const DEFAULT_COMPLETION_BADGE := preload(
	"res://assets/UI/build_phase/XPERC_COMP_ICON.png"
)
const PERFECT_COMPLETION_BADGE := preload(
	"res://assets/UI/build_phase/100PERC_COMP_ICON.png"
)

@export var select_button: Button
@export var preview: Button
@export var stat_value_label: Label
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


func set_reference_part(
	reference_part: PartResource,
	stat_multiplier: float = 1.0
) -> void:
	if stat_value_label == null:
		return

	if reference_part is HeadResource:
		var head_part := reference_part as HeadResource
		stat_value_label.text = "%ss" % _format_number(
			head_part.cooldown_seconds * stat_multiplier
		)
	elif reference_part is TorsoResource:
		var torso_part := reference_part as TorsoResource
		stat_value_label.text = "%d%%" % roundi(
			clampf(
				torso_part.damage_avoidance_chance * stat_multiplier,
				0.0,
				1.0
			) * 100.0
		)
	elif reference_part is DefResource:
		var defense_part := reference_part as DefResource
		stat_value_label.text = _format_number(
			defense_part.defense * stat_multiplier
		)
	elif reference_part is AtkResource:
		var attack_part := reference_part as AtkResource
		stat_value_label.text = _format_number(
			attack_part.attack_damage * stat_multiplier
		)
	else:
		stat_value_label.text = ""


func set_similarity(similarity: float) -> void:
	if similarity_label == null:
		return

	var percentage := roundi(clampf(similarity, 0.0, 1.0) * 100.0)
	similarity_label.text = "%d%%" % percentage

	var completion_badge := similarity_label.get_parent() as TextureRect
	if completion_badge != null:
		completion_badge.texture = (
			PERFECT_COMPLETION_BADGE
			if percentage == 100
			else DEFAULT_COMPLETION_BADGE
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


func _format_number(value: float) -> String:
	var formatted := "%.2f" % value
	while formatted.ends_with("0"):
		formatted = formatted.left(-1)
	return formatted.trim_suffix(".")
