extends Control

#change path
const WORLD_SCENE := "res://scenes/world/world.tscn"

func _ready() -> void:
	# optional: keyboard/controller starts on Play
	$CenterContainer/MainButtons/PLAY.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	# MVP option: just hide it / or show a simple popup later
	print("Settings clicked (MVP: ignore or add later)")
