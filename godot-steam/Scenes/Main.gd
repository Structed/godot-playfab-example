extends HBoxContainer

func _ready():
	# determine whether godot-steam addon is enabled
	if ClassDB.can_instantiate("Steam"):
		print_debug("Steam installed")
	else:
		print_debug("Steam is NOT installed")
		$LoginWithSteam.visible = false
		$LoginWithSteam.disconnect("pressed", _on_login_with_steam_pressed)

func _on_Register_pressed():
	SceneManager.goto_scene("res://Scenes/Register.tscn")

func _on_Login_pressed():
	SceneManager.goto_scene("res://Scenes/Login.tscn")

func _on_login_with_steam_pressed():
	SceneManager.goto_scene("res://Scenes/LoginSteam.tscn")
