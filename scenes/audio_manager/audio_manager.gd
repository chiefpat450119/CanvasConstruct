
extends Node

@export var sfx_player_scene: PackedScene
@export var sfx_players: Node
@export var bg_music_player : AudioStreamPlayer

@export_category("BG Music")
@export var main_menu_music : AudioStream
@export var build_music : AudioStream
@export var combat_music : AudioStream
@export var drawing_music : AudioStream

const MAIN_MENU_MUSIC_VOLUME : float = -15
const BUILD_MUSIC_VOLUME : float = -10
const COMBAT_MUSIC_VOLUME : float = -15
const DRAWING_MUSIC_VOLUME : float = -15
var cur_bg_music_volume : float = 0
var next_bg_song : AudioStream

func _ready() -> void:
	pass

## Plays given audio file at given volume and speed (optional, default is normal speed)
func play_SFX(audio_stream: AudioStream, volume : float, speed : float = 1.0) -> AudioStreamPlayer:
	var sfx_player : SFXPlayer = sfx_player_scene.instantiate()
	sfx_player.stream = audio_stream
	sfx_player.volume_db = volume
	sfx_player.pitch_scale = speed
	
	sfx_players.add_child(sfx_player)
	return sfx_player

func play_main_menu_music():
	pass # no menu music yet
	#bg_music_player.stream = main_menu_music

func play_build_music():
	cur_bg_music_volume = BUILD_MUSIC_VOLUME
	next_bg_song = build_music
	_fade_out()

func play_combat_music():
	cur_bg_music_volume = COMBAT_MUSIC_VOLUME
	next_bg_song = combat_music
	_fade_out()

func play_drawing_music():
	cur_bg_music_volume = DRAWING_MUSIC_VOLUME
	next_bg_song = drawing_music
	_fade_out()

func _fade_out():
	var tween := create_tween()
	tween.tween_property(bg_music_player, "volume_db", -30.0, 1)
	tween.tween_callback(_fade_in)

func _fade_in():
	bg_music_player.stream = next_bg_song
	bg_music_player.play()
	var tween := create_tween()
	tween.tween_property(bg_music_player, "volume_db", cur_bg_music_volume, 1)
