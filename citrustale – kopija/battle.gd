extends Node2D

# Переменные
var mandarin = null
var attack_texture = null
var mandarin_speed = 200
var current_level = 1
var is_fighting = false
var level_timer = null
var attack_timer = null
var box_width = 400
var box_height = 150

# HP система
var player_hp = 20
var player_max_hp = 20
var boss_hp = 100
var boss_max_hp = 100
var is_player_turn = true

# UI элементы
var player_hp_label = null
var boss_hp_label = null
var fight_btn = null
var act_btn = null
var item_btn = null
var mercy_btn = null
var message_label = null

func _ready():
	print("🎮 ========== BATTLE SCENE STARTED ==========")
	
	# Загружаем текстуру атаки
	attack_texture = load("res://sprites/arbyz_attack.png")
	if attack_texture:
		print("✅ Текстура арбуза загружена!")
	else:
		print("❌ Текстура арбуза НЕ загружена!")
	
	# Ищем BattleBox
	var battle_box = get_node_or_null("BattleBox")
	if battle_box == null:
		battle_box = _find_node_by_name(self, "BattleBox")
	
	if battle_box == null:
		print("❌ BattleBox не найден!")
		return
	print("✅ BattleBox найден!")
	
	# Ищем Mandarin
	mandarin = battle_box.get_node_or_null("Mandarin")
	if mandarin == null:
		mandarin = _find_node_by_name(self, "Mandarin")
	
	if mandarin == null:
		print("❌ Mandarin не найден!")
		return
	print("✅ Mandarin найден!")
	
	# Загружаем текстуру мандарина
	var mandarin_texture = load("res://objects/Mandarin.png")
	if mandarin_texture:
		mandarin.texture = mandarin_texture
		print("✅ Текстура мандарина назначена!")
	
	# Позиция мандарина
	mandarin.position = Vector2(200, 75)
	mandarin.z_index = 10
	mandarin.z_as_relative = false
	
	# Создаём UI
	_create_hp_ui()
	
	# Подключаем кнопки
	_connect_buttons()
	
	print("🎮 Всё готово!")
	print("==========================================")
	
	await get_tree().create_timer(0.5).timeout
	start_battle()

func _create_hp_ui():
	# HP игрока
	player_hp_label = Label.new()
	player_hp_label.text = "МАНДАРИН: %d/%d" % [player_hp, player_max_hp]
	player_hp_label.position = Vector2(20, 400)
	player_hp_label.add_theme_font_size_override("font_size", 20)
	player_hp_label.add_theme_color_override("font_color", Color.ORANGE)
	add_child(player_hp_label)
	
	# HP босса
	boss_hp_label = Label.new()
	boss_hp_label.text = "АРБУЗ: %d/%d" % [boss_hp, boss_max_hp]
	boss_hp_label.position = Vector2(450, 20)
	boss_hp_label.add_theme_font_size_override("font_size", 20)
	boss_hp_label.add_theme_color_override("font_color", Color.GREEN)
	add_child(boss_hp_label)
	
	# Сообщение
	message_label = Label.new()
	message_label.text = ""
	message_label.position = Vector2(120, 380)
	message_label.size = Vector2(400, 30)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(message_label)

func _connect_buttons():
	# Ищем кнопки всеми способами
	fight_btn = get_node_or_null("UI/Buttons/FightBtn")
	if fight_btn == null:
		fight_btn = _find_node_by_name(self, "FightBtn")
	if fight_btn == null:
		fight_btn = _find_node_by_name(self, "FightB")
	
	act_btn = get_node_or_null("UI/Buttons/ActBtn")
	if act_btn == null:
		act_btn = _find_node_by_name(self, "ActBtn")
	
	item_btn = get_node_or_null("UI/Buttons/ItemBtn")
	if item_btn == null:
		item_btn = _find_node_by_name(self, "ItemBtn")
	
	mercy_btn = get_node_or_null("UI/Buttons/MercyBtn")
	if mercy_btn == null:
		mercy_btn = _find_node_by_name(self, "MercyBtn")
	
	# Подключаем
	if fight_btn:
		fight_btn.pressed.connect(_on_fight)
		fight_btn.text = "⚔️ FIGHT"
		print("✅ FightBtn подключена!")
	else:
		print("❌ FightBtn НЕ НАЙДЕНА! Создаём...")
		_create_fight_button()
	
	if act_btn:
		act_btn.pressed.connect(_on_act)
		print("✅ ActBtn подключена!")
	
	if item_btn:
		item_btn.pressed.connect(_on_item)
		print("✅ ItemBtn подключена!")
	
	if mercy_btn:
		mercy_btn.pressed.connect(_on_mercy)
		print("✅ MercyBtn подключена!")

func _create_fight_button():
	fight_btn = Button.new()
	fight_btn.name = "FightBtn"
	fight_btn.text = "⚔️ FIGHT"
	fight_btn.position = Vector2(120, 420)
	fight_btn.custom_minimum_size = Vector2(100, 40)
	fight_btn.add_theme_font_size_override("font_size", 18)
	add_child(fight_btn)
	fight_btn.pressed.connect(_on_fight)
	print("✅ Кнопка FIGHT создана!")

func _process(delta):
	if not is_fighting:
		return
	
	if is_player_turn:
		return
	
	# Движение мандарина
	var direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		direction.y += 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		mandarin.position += direction * mandarin_speed * delta
	
	# Ограничения
	var margin = 15
	mandarin.position.x = clamp(mandarin.position.x, margin, box_width - margin)
	mandarin.position.y = clamp(mandarin.position.y, margin, box_height - margin)
	
	check_collisions()

func start_battle():
	print("🍉 ========== БИТВА НАЧАЛАСЬ! Уровень ", current_level, " ==========")
	is_fighting = true
	is_player_turn = true
	_update_ui()
	_show_message("Твой ход! Нажми FIGHT")
	print("✅ Жми FIGHT!")

func _on_fight():
	print("🔴 КНОПКА FIGHT НАЖАТА!")
	
	if not is_fighting:
		print("❌ Битва не идёт!")
		return
	
	if not is_player_turn:
		print("❌ Сейчас не твой ход!")
		return
	
	print("⚔️ АТАКА!")
	_show_message("️ Ты атакуешь арбуза!")
	
	var damage = randi_range(15, 25)
	boss_hp -= damage
	boss_hp = max(0, boss_hp)
	
	print("🗡️ Урон: ", damage, " | HP босса: ", boss_hp, "/", boss_max_hp)
	_update_ui()
	
	if boss_hp <= 0:
		_show_message("🎉 ПОБЕДА! Арбуз повержен!")
		print("🎉 ПОБЕДА!")
		is_fighting = false
		await get_tree().create_timer(2.0).timeout
		get_tree().call_deferred("change_scene_to_file", "res://forest_part_2.tscn")
		return
	
	is_player_turn = false
	_show_message("🍉 Арбуз летит! Уворачивайся!")
	print("🍉 Начинается фаза уклонения!")
	
	await get_tree().create_timer(1.0).timeout
	start_enemy_turn()

func start_enemy_turn():
	print(" Ход противника!")
	
	var attacks = get_node_or_null("Attacks")
	if attacks == null:
		print("❌ Attacks контейнер НЕ НАЙДЕН! Создаём...")
		attacks = Node2D.new()
		attacks.name = "Attacks"
		add_child(attacks)
		print("✅ Attacks контейнер создан!")
	
	start_attacks()
	
	var dodge_timer = Timer.new()
	dodge_timer.wait_time = 5.0 + (current_level * 2.0)
	dodge_timer.one_shot = true
	dodge_timer.timeout.connect(_end_enemy_turn)
	add_child(dodge_timer)

func _end_enemy_turn():
	print("✅ Ход противника закончен!")
	
	var attacks = get_node_or_null("Attacks")
	if attacks:
		for attack in attacks.get_children():
			attack.queue_free()
	
	is_player_turn = true
	_show_message("Твой ход! Нажми FIGHT")
	_update_ui()

func start_attacks():
	if attack_timer:
		attack_timer.queue_free()
	
	attack_timer = Timer.new()
	attack_timer.wait_time = get_attack_interval()
	attack_timer.autostart = true
	attack_timer.timeout.connect(_spawn_attack)
	add_child(attack_timer)
	
	print("️ Таймер атак: ", get_attack_interval(), " сек")

func get_attack_interval():
	match current_level:
		1: return 1.5
		2: return 1.0
		3: return 0.5
		_: return 1.0

func _spawn_attack():
	print("🍉 _spawn_attack вызван!")
	print("   is_player_turn = ", is_player_turn)
	print("   attack_texture = ", attack_texture)
	
	if attack_texture == null or is_player_turn:
		print("❌ Не создаём арбуз (текстура=null или ход игрока)")
		return
	
	var attack = Sprite2D.new()
	attack.texture = attack_texture
	
	var random_x = randi_range(20, box_width - 20)
	attack.position = Vector2(random_x, -20)
	
	print("   Создаём арбуз на позиции: ", attack.position)
	
	var attacks = get_node_or_null("Attacks")
	if attacks:
		attacks.add_child(attack)
		print("✅ Арбуз добавлен в Attacks контейнер!")
	else:
		print("❌ Attacks контейнер НЕ НАЙДЕН!")
		attack.queue_free()
		return
	
	# Скорость падения
	var fall_speed = 100 + (current_level - 1) * 80
	var distance = box_height + 40
	var duration = distance / fall_speed
	
	print("   Скорость: ", fall_speed, " | Время: ", duration, " сек")
	
	var tween = create_tween()
	tween.tween_property(attack, "position:y", box_height + 20, duration)
	tween.tween_callback(attack.queue_free)

func check_collisions():
	if is_player_turn:
		return
	
	var attacks = get_node_or_null("Attacks")
	if attacks == null:
		return
	
	for attack in attacks.get_children():
		var distance = mandarin.global_position.distance_to(attack.global_position)
		if distance < 20:
			print(" СТОЛКНОВЕНИЕ! Урон игроку!")
			player_hp -= 5
			player_hp = max(0, player_hp)
			_update_ui()
			
			if player_hp <= 0:
				_show_message("💀 GAME OVER!")
				print("💀 GAME OVER!")
				is_fighting = false
				await get_tree().create_timer(2.0).timeout
				get_tree().call_deferred("change_scene_to_file", "res://MainMenu.tscn")
			return

func _update_ui():
	if player_hp_label:
		player_hp_label.text = "МАНДАРИН: %d/%d" % [player_hp, player_max_hp]
	if boss_hp_label:
		boss_hp_label.text = "АРБУЗ: %d/%d" % [boss_hp, boss_max_hp]

func _show_message(text: String):
	if message_label:
		message_label.text = text

func _on_act():
	print("🎭 ACT!")
	_show_message("Ты осматриваешь арбуза...")

func _on_item():
	print("🎒 ITEM!")
	if player_hp < player_max_hp:
		var heal = 10
		player_hp = min(player_max_hp, player_hp + heal)
		_update_ui()
		_show_message("Ты восстановил %d HP!" % heal)
	else:
		_show_message("HP уже полное!")

func _on_mercy():
	print("🕊️ MERCY!")
	_show_message("Арбуз не принимает пощаду!")

func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var result = _find_node_by_name(child, target_name)
		if result != null:
			return result
	return null
