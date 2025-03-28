extends Node2D

var audio_player: AudioStreamPlayer
var audio_signals: Dictionary = {}
var ball_scene = preload("res://ball.tscn")
var signals: Array = []       # массив команд
var times: Array = []         # массив времени
var centroids: Array = []     # массив спектральных центроидов
var rms_values: Array = []    # массив RMS значений
var beats: Array = []         # массив битов
var tempo: float = 0.0        # темп
var is_ready_to_play = false  # флаг готовности к воспроизведению
var spawned_balls = {}  # Словарь для отслеживания созданных шаров
var checked_balls = {}  # Словарь для отслеживания проверенных шаров
var combo = 0  # Добавляем переменную для подсчета комбо

# Константы для позиций и цветов шаров
const BALL_POSITIONS = {
	"up": 450,
	"right": 500,
	"left": 550,
	"down": 600
}

const BALL_COLORS = {
	"up": Color.GREEN,
	"right": Color.PINK,
	"left": Color.RED,
	"down": Color.BLUE
}

# В начале файла добавим константы для иконок
const BALL_TEXTURES = {
	"up": preload("res://assets/up.png"),
	"right": preload("res://assets/right.png"),
	"left": preload("res://assets/left.png"),
	"down": preload("res://assets/down.png")
}

# Время в секундах, за которое шар должен достичь Bar
const TIME_TO_REACH = 3.0

@onready var result_label = $ResultLabel  # Добавьте Label в сцену
@onready var score_label = $ScoreLabel
@onready var pause_buttons = $PauseButtons

# Словарь для соответствия клавиш и команд
const KEY_COMMANDS = {
	KEY_UP: "up",
	KEY_RIGHT: "right",
	KEY_LEFT: "left",
	KEY_DOWN: "down",
	# Добавляем WASD
	KEY_W: "up",
	KEY_D: "right",
	KEY_A: "left",
	KEY_S: "down"
}

# Добавим таймер для перехода в меню
var end_timer: Timer

var audio_analyzer = preload("res://audio_analyzer.gd").new()

# В начале файла добавим переменную для отслеживания состояния паузы
var is_paused = false

func _ready():
	# Создаем и настраиваем таймер
	end_timer = Timer.new()
	end_timer.one_shot = true  # Таймер сработает только один раз
	end_timer.wait_time = 1.0  # 1 секунда
	end_timer.timeout.connect(_on_end_timer_timeout)
	add_child(end_timer)
	
	Global.reset_score()  # Сбрасываем счет в начале
	
	if Global.selected_audio_path != "":
		# Создаем плеер
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		
		# Загружаем и устанавливаем аудио файл
		var audio_stream = load_audio_file(Global.selected_audio_path)
		if audio_stream:
			audio_player.stream = audio_stream
			
			# Запускаем парсер перед воспроизведением
			parse_audio_file()
			
			# Воспроизведение начнется только после успешного парсинга

	# Создаем визуализаторы программно
	var visualizer_positions = [
		Vector2(200, 198),
		Vector2(200, 248),
		Vector2(200, 298),
		Vector2(200, 348)
	]
	
	for pos in visualizer_positions:
		var visualizer = Node2D.new()
		visualizer.set_script(load("res://audio_visualizer.gd"))
		visualizer.position = pos
		add_child(visualizer)
	combo = 0  # Инициализируем комбо при старте
	
	# Инициализируем счет
	if score_label:
		score_label.text = Translations.translate("score") % Global.score
	
	# Подключаем сигналы кнопок
	$PauseButtons/RestartButton.pressed.connect(_on_restart_pressed)
	$PauseButtons/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Подключаем слайдер громкости
	$PauseButtons/VolumeControl/VolumeSlider.value_changed.connect(_on_volume_changed)
	
	# Устанавливаем начальное значение громкости
	if audio_player:
		$PauseButtons/VolumeControl/VolumeSlider.value = audio_player.volume_db
	
	# Устанавливаем тексты кнопок
	if $PauseButtons/RestartButton:
		$PauseButtons/RestartButton.text = Translations.translate("restart")
	if $PauseButtons/QuitButton:
		$PauseButtons/QuitButton.text = Translations.translate("quit")
	if $PauseButtons/VolumeControl/Label:
		$PauseButtons/VolumeControl/Label.text = Translations.translate("volume_label")
	
	# Подключаем обработку изменения размера окна
	get_tree().root.size_changed.connect(_on_window_resize)
	
	# Сразу обновляем размер фона
	call_deferred("_on_window_resize")

func start_playback():
	if is_ready_to_play and audio_player and not audio_player.playing:
		print("Начинаем воспроизведение")
		audio_player.play()

func load_audio_file(path: String) -> AudioStream:
	# Загружаем аудио файл
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var audio_stream
		if path.ends_with(".mp3"):
			audio_stream = AudioStreamMP3.new()
		elif path.ends_with(".wav"):
			audio_stream = AudioStreamWAV.new()
		
		if audio_stream:
			audio_stream.data = file.get_buffer(file.get_length())
			return audio_stream
	return null 

func parse_audio_file():
	if audio_player and audio_player.stream:
		var analysis = audio_analyzer.analyze_audio(audio_player.stream)
		
		signals = analysis.signals
		times = analysis.times
		centroids = analysis.centroids
		rms_values = analysis.rms_values
		beats = analysis.beats
		tempo = analysis.tempo
		
		Global.total_notes = signals.size()
		
		is_ready_to_play = true
		start_playback()

func _process(_delta):
	if audio_player and audio_player.playing:
		var current_time = audio_player.get_playback_position()
		
		# Проверяем, закончилась ли песня
		if current_time >= audio_player.stream.get_length() - 0.1:
			audio_player.stop()
			end_timer.start()
		
		# Проверяем пропущенные ноты
		for i in range(signals.size()):
			var signal_time = float(times[i])
			
			# Если нота уже прошла мимо Bar и не была проверена
			if current_time > signal_time + 0.1 and not checked_balls.has(i):
				checked_balls[i] = true
				if not Global.missed_notes_indices.has(i):
					Global.missed_notes += 1
					Global.missed_notes_indices.append(i)
					result_label.set_text_with_effect(Translations.translate("miss"))
					result_label.modulate = Color.WHITE
					combo = 0
		
		# Проверяем сигналы для создания новых шаров
		for i in range(signals.size()):
			var signal_time = float(times[i])
			var spawn_time = signal_time - TIME_TO_REACH
			
			# Пропускаем, если шар для этого времени уже был создан
			if spawned_balls.has(i):
				continue
			
			# Проверяем время создания
			if current_time >= spawn_time:
				var cmd = signals[i]
				spawn_ball(cmd)
				spawned_balls[i] = true  # Отмечаем, что шар создан

func spawn_ball(cmd: String):
	var ball = ball_scene.instantiate()
	ball.add_to_group("balls")
	add_child(ball)
	
	# Устанавливаем начальную позицию (справа экрана)
	var viewport_size = get_viewport().get_visible_rect().size
	ball.position = Vector2(viewport_size.x + 50, BALL_POSITIONS[cmd])
	
	# Устанавливаем цвет и текстуру
	var color = BALL_COLORS[cmd]
	var texture = BALL_TEXTURES[cmd]
	ball.setup(color, texture)
	
	# Рассчитываем скорость
	var distance = ball.position.x - ball.target_x
	ball.speed = distance / TIME_TO_REACH
	
	print("Шар создан на позиции: ", ball.position, " со скоростью: ", ball.speed)

func handle_signal(cmd: String):
	match cmd:
		"up":
			print("Сигнал вверх")
			# Добавьте здесь логику обработки сигнала
		"down":
			print("Сигнал вниз")
		"left":
			print("Сигнал влево")
		"right":
			print("Сигнал вправо") 

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()
		elif KEY_COMMANDS.has(event.keycode) and not is_paused:  # Проверяем, не на паузе ли игра
			var command = KEY_COMMANDS[event.keycode]
			check_hit(command)

func check_hit(command: String):
	var target_color = BALL_COLORS[command]
	var current_time = audio_player.get_playback_position()
	var hit_success = false
	
	# Проверяем все активные шары
	for ball in get_tree().get_nodes_in_group("balls"):
		if is_same_color(ball.sprite.modulate, target_color):
			if ball.is_touching_bar:
				combo += 1
				hit_success = true
				
				# Добавляем очки
				var points = Global.calculate_hit_points(combo)
				Global.score += points
				if score_label:
					score_label.text = Translations.translate("score") % Global.score
				
				# Отмечаем ноту как проверенную
				for i in range(signals.size()):
					if not checked_balls.has(i) and abs(current_time - float(times[i])) < 0.1:
						checked_balls[i] = true
						break
				
				if combo >= 5:
					result_label.set_text_with_effect(Translations.translate("perfect_combo") % [combo, points])
				else:
					# Показываем базовые очки с учетом сложности
					result_label.set_text_with_effect(Translations.translate("perfect") % points)
				
				result_label.modulate = Color.GREEN
				ball.destroy()
				return
	
	# Если промахнулись
	if not hit_success:
		combo = 0
		# Находим ближайшую активную ноту и отмечаем её как промах
		for i in range(signals.size()):
			if not checked_balls.has(i) and not Global.missed_notes_indices.has(i):
				var signal_time = float(times[i])
				if abs(current_time - signal_time) < 0.1:
					checked_balls[i] = true
					Global.missed_notes += 1
					Global.missed_notes_indices.append(i)
					break
		
		result_label.set_text_with_effect(Translations.translate("miss"))
		result_label.modulate = Color.WHITE

# Функция для сравнения цветов с погрешностью
func is_same_color(color1: Color, color2: Color, tolerance: float = 0.01) -> bool:
	return abs(color1.r - color2.r) < tolerance and \
		   abs(color1.g - color2.g) < tolerance and \
		   abs(color1.b - color2.b) < tolerance and \
		   abs(color1.a - color2.a) < tolerance

func _on_end_timer_timeout():
	# Переходим к экрану счета вместо меню
	get_tree().change_scene_to_file("res://score_menu.tscn")

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		# Ставим игру на паузу
		if audio_player:
			audio_player.stream_paused = true
		get_tree().paused = true
		result_label.text = Translations.translate("pause")
		result_label.modulate = Color.WHITE
		pause_buttons.visible = true
	else:
		# Снимаем с паузы
		if audio_player:
			audio_player.stream_paused = false
		get_tree().paused = false
		result_label.text = ""
		pause_buttons.visible = false

func _on_restart_pressed():
	# Перезапускаем текущий уровень
	get_tree().paused = false  # Важно снять паузу перед перезапуском
	get_tree().reload_current_scene()

func _on_quit_pressed():
	# Возвращаемся в главное меню
	get_tree().paused = false  # Важно снять паузу перед выходом
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_volume_changed(value: float):
	if audio_player:
		audio_player.volume_db = value

func _on_window_resize():
	# Обновляем размер фона при изменении размера окна
	var window_size = get_viewport().get_visible_rect().size
	$Background.size = window_size
	$Background.position = Vector2.ZERO  # Убеждаемся, что фон начинается с левого верхнего угла
