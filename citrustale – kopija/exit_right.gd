extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# Загружаем новую сцену
		var new_scene = load("res://forest_part_2.tscn").instantiate()
		get_tree().root.add_child(new_scene)
		
		# Находим метку спавна
		var spawn_point = new_scene.get_node("PlayerSpawn")
		
		# Перемещаем игрока туда
		body.global_position = spawn_point.global_position
		
		# Удаляем старую сцену
		queue_free()
