extends Node

const MIN_WINDOW_SIZE = Vector2i(800, 450)  # 16:9 минимальный размер
const DEFAULT_WINDOW_SIZE = Vector2i(1152, 648)  # Текущий размер окна

func _ready():
	setup_window()

func setup_window():
	var window = get_tree().root.get_window()
	
	# Устанавливаем минимальный размер окна
	window.min_size = MIN_WINDOW_SIZE
	
	# Разрешаем изменение размера окна
	window.set_flag(Window.FLAG_RESIZE_DISABLED, false)
	
	# Используем CONTENT_SCALE_MODE_CANVAS_ITEMS для лучшего качества
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	# CONTENT_SCALE_ASPECT_EXPAND позволяет контенту заполнять всё окно
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# Проверяем и корректируем текущий размер окна если он меньше минимального
	if window.size.x < MIN_WINDOW_SIZE.x or window.size.y < MIN_WINDOW_SIZE.y:
		window.size = MIN_WINDOW_SIZE
	
	# Центрируем окно
	var screen_size = DisplayServer.screen_get_size()
	var window_size = window.size
	window.position = (screen_size - window_size) / 2

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		# При изменении размера окна проверяем и применяем ограничения
		var window = get_tree().root.get_window()
		if window.size.x < MIN_WINDOW_SIZE.x or window.size.y < MIN_WINDOW_SIZE.y:
			window.size = MIN_WINDOW_SIZE

# Удаляем неиспользуемую функцию update_ui_scale, так как масштабирование 
# происходит автоматически через настройки viewport 
