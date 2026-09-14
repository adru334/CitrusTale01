extends CharacterBody2D

# Скорость движения
var speed = 200

# Словарь со спрайтами для каждого направления
var sprites = {
	"up": preload("res://sprites/lemon_up.png"),
	"down": preload("res://sprites/lemon_down.png"),
	"left": preload("res://sprites/lemon_left.png"),
	"right": preload("res://sprites/lemon_right.png")
}

# Текущее направление (по умолчанию вниз)
var current_direction = "down"

func _physics_process(delta):
	# Получаем ввод с клавиатуры
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Если есть движение
	if input_direction != Vector2.ZERO:
		# Нормализуем вектор (чтобы по диагонали не было быстрее)
		input_direction = input_direction.normalized()
		
		# Определяем направление для спрайта
		if abs(input_direction.x) > abs(input_direction.y):
			# Движение по горизонтали
			if input_direction.x > 0:
				current_direction = "right"
			else:
				current_direction = "left"
		else:
			# Движение по вертикали
			if input_direction.y > 0:
				current_direction = "down"
			else:
				current_direction = "up"
		
		# Меняем спрайт
		$Sprite.texture = sprites[current_direction]
		
		# Устанавливаем скорость
		velocity = input_direction * speed
	else:
		# Если не движемся — останавливаемся
		velocity = Vector2.ZERO
	
	# Применяем движение
	move_and_slide()
