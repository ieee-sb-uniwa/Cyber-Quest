extends AudioStreamPlayer
var music_vol = 0.0
const menu_music = preload("res://Assets/CyberQuest_Assets/Music/TitleMusic.mp3")
var current_music

func _play_music(music: AudioStream, volume = 0.0):
    if stream == music:
        volume_db = volume
        return
    
    stream = music
    current_music = music
    volume_db = volume
    play()

func play_music_menu(volume=0.0):   # Ideally only call through menu.gd, so that is always uses the desired music_vol
    music_vol = volume
    _play_music(menu_music, music_vol)

func _on_finished() -> void:
    _play_music(current_music)  # Unsure if this is even necessary after enabling "loop" on .mp3 file