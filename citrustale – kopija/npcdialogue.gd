extends CharacterBody2D  # ← ПЕРВАЯ СТРОКА!

var player_nearby = false
var e_pressed = false

func _ready():
	var interaction_zone = $InteractionZone
	if interaction_zone:
		interaction_zone.body_entered.connect(_on_body_entered)
		interaction_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_nearby = true
		print("✅ Игрок рядом! Нажми E")

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false

func _process(delta):
	if player_nearby and not e_pressed and Input.is_key_pressed(KEY_E):
		e_pressed = true
		print("🎮 E НАЖАТА!")
		
		var parent = get_parent()
		while parent != null:
			var dialogue_box = parent.get_node_or_null("DialogueBox")
			if dialogue_box:
				var dialogue_steps = [
					{
						"speaker": "Арбуз",
						"text": "Эй лимон что ты тут делаешь? Это частная территория!",
						"choices": ["Эй арбуз карапуз не мешайся проходу"]
					},
					{
						"speaker": "Арбуз",
						"text": "Ты что борзый? Давай сразимся 1 на 1!",
						"choices": ["Ну давай"]
					}
				]
				dialogue_box.start_dialogue_steps(dialogue_steps)
				print("🍉 ДИАЛОГ ЗАПУЩЕН!")
				return
			parent = parent.get_parent()
		
		print("❌ DialogueBox НЕ НАЙДЕН!")
	
	if not Input.is_key_pressed(KEY_E):
		e_pressed = false
