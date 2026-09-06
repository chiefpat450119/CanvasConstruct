
extends Node

@export var sfx_player_scene: PackedScene
@export var sfx_players: Node

func play_SFX(audio_stream: AudioStream, volume : float, speed : float = 1.0) -> AudioStreamPlayer:
	var sfx_player : SFXPlayer = sfx_player_scene.instantiate()
	sfx_player.stream = audio_stream
	sfx_player.volume_db = volume
	sfx_player.pitch_scale = speed
	
	sfx_players.add_child(sfx_player)
	return sfx_player
