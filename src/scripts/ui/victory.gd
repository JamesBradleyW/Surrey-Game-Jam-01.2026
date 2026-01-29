extends Control

const MENU_SCENE := "res://scenes/ui/MainMenu.tscn"

func _ready() -> void:
	$CenterContainer/VBoxContainer/MainMenuButton.grab_focus()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
