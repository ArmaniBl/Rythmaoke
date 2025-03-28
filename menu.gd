extends Node

var file_dialog: FileDialog

@onready var quit_button = $QuitButton

func _ready():
	# Инициализируем FileDialog
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	
	# Настраиваем параметры диалога
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.mp3", "*.mp4") # Поддерживаемые аудио форматы
	
	# Подключаем сигнал выбора файла
	file_dialog.file_selected.connect(_on_file_selected)
	
	$DifficultyButtons/EasyButton.pressed.connect(_on_easy_pressed)
	$DifficultyButtons/NormalButton.pressed.connect(_on_normal_pressed)
	$DifficultyButtons/HardButton.pressed.connect(_on_hard_pressed)
	
	# Подключаем кнопку настроек
	$SettingsButton.pressed.connect(_on_settings_pressed)
	
	# Обновляем список песен
	update_song_list()
	
	# Обновляем тексты
	$Label.text = "Rhythmaoke"  # Оставляем название игры без перевода
	$Button.text = Translations.translate("select_file")
	$SongList/SongListContainer/SongsLabel.text = Translations.translate("song_history")
	$SettingsButton.text = Translations.translate("settings")
	update_difficulty_buttons()

	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		quit_button.text = Translations.translate("quit_game")

	# Подключаем обработку изменения размера окна
	get_tree().root.size_changed.connect(_on_window_resize)
	
	# Сразу обновляем размер фона
	call_deferred("_on_window_resize")

func update_song_list():
	var container = $SongList/SongListContainer
	
	# Очищаем старый список, пропуская метку заголовка
	for child in container.get_children():
		if child.name != "SongsLabel":
			child.queue_free()
	
	# Добавляем каждую песню из истории
	for path in Global.song_records:
		var record = Global.song_records[path]
		
		# Создаем кнопку-контейнер для всей строки
		var button = Button.new()
		button.flat = true
		button.custom_minimum_size.y = 40
		button.pressed.connect(_on_song_selected.bind(path))
		
		# Добавляем стилизацию при наведении
		button.mouse_entered.connect(_on_song_button_hover.bind(button))
		button.mouse_exited.connect(_on_song_button_exit.bind(button))
		
		# Создаем контейнер для текста внутри кнопки
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Создаем метку с названием песни
		var name_label = Label.new()
		name_label.text = path.get_file()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.modulate = Color(0.8, 0.2, 1.0, 1.0)  # Тот же цвет, что и у заголовка
		
		# Создаем метку с рекордом
		var record_label = Label.new()
		var difficulty_text = ""
		match record.difficulty:
			0.5: difficulty_text = Translations.translate("easy")
			1.0: difficulty_text = Translations.translate("normal")
			1.5: difficulty_text = Translations.translate("hard")
		record_label.text = Translations.translate("record") % [record.score, difficulty_text]
		record_label.modulate = Color(0.8, 0.2, 1.0, 1.0)  # Тот же цвет, что и у заголовка
		
		# Собираем всё вместе
		hbox.add_child(name_label)
		hbox.add_child(record_label)
		button.add_child(hbox)
		container.add_child(button)

func _on_song_selected(path: String):
	Global.selected_audio_path = path
	get_tree().change_scene_to_file("res://playground.tscn")

func _on_file_selected(path: String):
	print("Выбранный файл:", path)
	Global.selected_audio_path = path
	get_tree().change_scene_to_file("res://playground.tscn")

func _on_easy_pressed():
	Global.set_difficulty("easy")
	update_difficulty_buttons()

func _on_normal_pressed():
	Global.set_difficulty("normal")
	update_difficulty_buttons()

func _on_hard_pressed():
	Global.set_difficulty("hard")
	update_difficulty_buttons()

func update_difficulty_buttons():
	$DifficultyButtons/Label.text = Translations.translate("difficulty")
	$DifficultyButtons/EasyButton.text = Translations.translate("easy")
	$DifficultyButtons/NormalButton.text = Translations.translate("normal")
	$DifficultyButtons/HardButton.text = Translations.translate("hard")
	
	# Визуально отмечаем выбранную сложность
	$DifficultyButtons/EasyButton.modulate = Color.WHITE
	$DifficultyButtons/NormalButton.modulate = Color.WHITE
	$DifficultyButtons/HardButton.modulate = Color.WHITE
	
	match Global.difficulty:
		0.5:
			$DifficultyButtons/EasyButton.modulate = Color.GREEN
		1.0:
			$DifficultyButtons/NormalButton.modulate = Color.GREEN
		1.5:
			$DifficultyButtons/HardButton.modulate = Color.GREEN

# Функция для кнопки выбора файла
func _on_button_pressed():
	file_dialog.popup_centered(Vector2(800, 600))

# Добавляем функции для обработки наведения
func _on_song_button_hover(button: Button):
	# Создаем эффект при наведении
	button.modulate = Color(1.2, 1.2, 1.2, 1.0)  # Делаем немного ярче
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND  # Меняем курсор

func _on_song_button_exit(button: Button):
	# Возвращаем нормальный вид
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_window_resize():
	# Обновляем размер фона при изменении размера окна
	var window_size = get_viewport().get_visible_rect().size
	$Background.size = window_size
	$Background.position = Vector2.ZERO  # Убеждаемся, что фон начинается с левого верхнего угла
