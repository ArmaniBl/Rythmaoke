extends Node2D

var firework_scene = preload("res://firework.gd")
var firework_timer: Timer

@onready var stats_label = $StatsLabel
@onready var repeat_button = $Repeat
@onready var new_game_button = $NewGame

func _ready():
	# Дождемся следующего кадра, чтобы все ноды были готовы
	await get_tree().process_frame
	
	# Обновляем тексты кнопок
	if repeat_button:
		repeat_button.text = Translations.translate("restart")
	if new_game_button:
		new_game_button.text = Translations.translate("new_game")
	
	# Показываем статистику
	var accuracy = 0.0
	var total_notes = Global.missed_notes + Global.score
	if total_notes > 0:
		accuracy = (float(Global.score) / total_notes) * 100.0
	
	if stats_label:
		stats_label.text = """
		%s: %d
		%s: %d
		%s: %.1f%%
		%s: %d
		""" % [
			Translations.translate("total_notes"), total_notes,
			Translations.translate("missed_notes"), Global.missed_notes,
			Translations.translate("accuracy"), accuracy,
			Translations.translate("final_score"), Global.score
		]
	
	if accuracy == 100:
		# Создаем таймер для периодического запуска фейерверков
		firework_timer = Timer.new()
		firework_timer.wait_time = 0.5
		firework_timer.timeout.connect(_spawn_firework)
		add_child(firework_timer)
		firework_timer.start()
	
	# Сохраняем рекорд
	Global.update_record(Global.selected_audio_path, Global.score)
	
	# Подключаем обработку изменения размера окна
	get_tree().root.size_changed.connect(_on_window_resize)
	
	# Сразу обновляем размер фона
	call_deferred("_on_window_resize")

func _spawn_firework():
	var firework = Node2D.new()
	firework.set_script(firework_scene)
	# Случайная позиция в верхней части экрана
	firework.position = Vector2(
		randf_range(100, 1050),
		randf_range(100, 300)
	)
	add_child(firework)

func _on_repeat_pressed():
	if firework_timer:
		firework_timer.stop()
	# Возвращаемся к той же песне
	get_tree().change_scene_to_file("res://playground.tscn")

func _on_new_game_pressed():
	if firework_timer:
		firework_timer.stop()
	# Возвращаемся в главное меню
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_window_resize():
	# Обновляем размер фона при изменении размера окна
	var window_size = get_viewport().get_visible_rect().size
	$Background.size = window_size
	$Background.position = Vector2.ZERO  # Убеждаемся, что фон начинается с левого верхнего угла
