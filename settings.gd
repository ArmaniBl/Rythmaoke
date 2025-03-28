extends Node2D

@onready var ru_button = $LanguageControl/LanguageOptions/RuButton
@onready var en_button = $LanguageControl/LanguageOptions/EnButton
@onready var title_label = $Title
@onready var back_button = $BackButton
@onready var language_label = $LanguageControl/Label
@onready var fullscreen_check = $DisplayControl/FullscreenCheck
@onready var display_label = $DisplayControl/Label

func _ready():
	# Дождемся следующего кадра, чтобы все ноды были готовы
	await get_tree().process_frame
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if ru_button:
		ru_button.pressed.connect(_on_ru_pressed)
	
	if en_button:
		en_button.pressed.connect(_on_en_pressed)
	
	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
		# Установить текущее состояние
		fullscreen_check.button_pressed = get_tree().root.get_window().mode == Window.MODE_FULLSCREEN
		
		# Отключаем изменение размера в полноэкранном режиме
		if fullscreen_check.button_pressed:
			get_tree().root.get_window().set_flag(Window.FLAG_RESIZE_DISABLED, true)
	
	update_language_buttons()
	update_texts()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_ru_pressed():
	Translations.set_language("ru")
	update_language_buttons()
	update_texts()

func _on_en_pressed():
	Translations.set_language("en")
	update_language_buttons()
	update_texts()

func update_language_buttons():
	if not ru_button or not en_button:
		return
		
	ru_button.modulate = Color.WHITE
	en_button.modulate = Color.WHITE
	
	match Translations.current_language:
		"ru": 
			if ru_button:
				ru_button.modulate = Color.GREEN
		"en": 
			if en_button:
				en_button.modulate = Color.GREEN

func update_texts():
	if title_label:
		title_label.text = Translations.translate("settings")
	if back_button:
		back_button.text = Translations.translate("back")
	if language_label:
		language_label.text = Translations.translate("language")
	if display_label:
		display_label.text = Translations.translate("display")
	if fullscreen_check:
		fullscreen_check.text = Translations.translate("fullscreen")

func _on_fullscreen_toggled(button_pressed: bool):
	var window = get_tree().root.get_window()
	if button_pressed:
		# Сохраняем текущий размер окна перед переходом в полноэкранный режим
		window.set_flag(Window.FLAG_RESIZE_DISABLED, true)
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		window.set_flag(Window.FLAG_RESIZE_DISABLED, false)
		# Возвращаем окно к дефолтному размеру при выходе из полноэкранного режима
		window.min_size = Vector2i(800, 450)  # Минимальный размер
		window.size = Vector2i(1152, 648)  # Дефолтный размер
		# Центрируем окно
		var screen_size = DisplayServer.screen_get_size()
		window.position = (screen_size - window.size) / 2
