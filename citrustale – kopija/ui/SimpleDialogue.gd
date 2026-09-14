extends Control

@onready var speaker_label = $ColorRect/VBoxContainer/SpeakerName
@onready var dialogue_label = $ColorRect/VBoxContainer/DialogueText
@onready var choices_container = $ColorRect/VBoxContainer/ChoicesContainer

var is_typing = false
var current_step = 0
var dialogue_steps = []

func _ready():
	hide()

func start_dialogue_steps(steps: Array):
	dialogue_steps = steps
	current_step = 0
	_show_step()

func _show_step():
	if current_step >= dialogue_steps.size():
		hide()
		return
	
	var step = dialogue_steps[current_step]
	var speaker = step["speaker"]
	var text = step["text"]
	var choices = step.get("choices", [])
	
	show()
	speaker_label.text = speaker.to_upper() + ":"
	dialogue_label.text = ""
	
	for child in choices_container.get_children():
		child.queue_free()
	
	is_typing = true
	_type_text(text, choices)

func _type_text(text: String, choices: Array):
	for letter in text.split(""):
		dialogue_label.text += letter
		await get_tree().create_timer(0.05).timeout
	is_typing = false
	
	if choices.size() > 0:
		_create_buttons(choices)

func _create_buttons(choices: Array):
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i]
		btn.pressed.connect(_on_choice.bind(i))
		choices_container.add_child(btn)

func _on_choice(index: int):
	print("Выбран вариант №", index)
	current_step += 1
	
	if current_step >= dialogue_steps.size():
		print("🍉 Конец диалога! Запускаем битву...")
		get_tree().change_scene_to_file("res://battle_scene.tscn")
	else:
		_show_step()

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		if not is_typing:
			hide()
