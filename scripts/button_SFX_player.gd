class_name ButtonSFXPlayer
extends Button

@export var hover_SFX : AudioStream = preload("res://assets/SFX/UI Hover.wav")
@export var click_SFX : AudioStream = preload("res://assets/SFX/UI Press Final.wav")

func _ready() -> void:
	mouse_entered.connect(_on_hover)
	button_down.connect(_on_click)

func _on_hover() -> void:
	AudioManager.play_SFX(hover_SFX, -10)

func _on_click() -> void:
	AudioManager.play_SFX(click_SFX, -10)
