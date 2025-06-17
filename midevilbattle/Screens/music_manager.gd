class_name MusicManager
extends Node
@onready var music_player = $MusicStreamPlayer
var music = [preload("res://Assets/Sounds/medieval-ambient-236809.mp3"), preload("res://Assets/Sounds/medieval-background-196571.mp3"), preload("res://Assets/Sounds/medieval-fantasy-142837.mp3"
), preload("res://Assets/Sounds/mountain-knight-castle-medieval-fantasy-orchestral-music-264986.mp3")]
@onready var sfx_player = [$sfx, $sfx2, $sfx3, $sfx4, $sfx5, $sfx6, $sfx7, $sfx8, $sfx9, $sfx10, $sfx11, $sfx12, $sfx13, $sfx14, $sfx15, $sfx16]
var sound_effect = {
	"dagger" : preload("res://Assets/Sounds/hit/dagger.wav"),
	"wolf" : preload("res://Assets/Sounds/Wolf.wav"), 
	"doom" : preload("res://Assets/Sounds/Welcome To Your Doom!.wav"), 
	"sword": preload("res://Assets/Sounds/hit/knife-slice-41231 (mp3cut.net).mp3"),
	"bearattack": preload("res://Assets/Sounds/hit/bear-191995.mp3"),
	"beardead": preload("res://Assets/Sounds/hit/bearsound.wav"),
	"skeleton": preload("res://Assets/Sounds/hit/bone-crack-3-121580+%28mp3cut.net%29.mp3"), 
	"eat": preload("res://Assets/Sounds/hit/apple-crunch-215258 (mp3cut.net).mp3"),
	"hurt": preload("res://Assets/Sounds/hit/Uh.wav"),
	"welcome": preload("res://Assets/Sounds/Welcome To Your Doom!.wav")
}
var hits = [preload("res://Assets/Sounds/hit/2AH.wav"), preload("res://Assets/Sounds/hit/2BH.wav"), preload("res://Assets/Sounds/hit/2CH.wav"), preload("res://Assets/Sounds/hit/2DH.wav"), preload("res://Assets/Sounds/hit/2EH.wav")]
func _ready() -> void:
	music.shuffle()
	music_player.stream = music[0]
	music_player.play()
	
func _on_music_stream_player_finished() -> void:
	music.shuffle()
	music_player.stream = music[1]
	music_player.play()

func sfx_play(sound_to_play: String):
	var sfx_to_use: AudioStreamPlayer
	for sfx: AudioStreamPlayer in sfx_player:
		if sfx.stream == null: 
			sfx_to_use = sfx
	if sfx_to_use != null:
		if sound_to_play != "hit":
			print("in_hereplaying")
			sfx_to_use.stream = sound_effect[sound_to_play]
			sfx_to_use.play()
			return
		else:
			hits.shuffle()
			sfx_to_use.stream = hits[0]
			sfx_to_use.play()

func _process(delta: float) -> void:
	for sfx: AudioStreamPlayer in sfx_player:
			if sfx.stream != null and sfx.playing == false: 
				sfx.stream = null
