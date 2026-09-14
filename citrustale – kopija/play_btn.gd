extends Control

func _ready():
	# Только размер, позицию не трогаем!
	$PlayBtn.stretch_mode = TextureButton.STRETCH_SCALE
	$PlayBtn.size = Vector2(300, 100)
	
	$PlayBtn.pressed.connect(_on_play_pressed)
	
	if $MenuMusic:
		$MenuMusic.play()

func _on_play_pressed():
	print("ИГРАТЬ нажата!")
	get_tree().change_scene_to_file("res://forets_start.tscn")
