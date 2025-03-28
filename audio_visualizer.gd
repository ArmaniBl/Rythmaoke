extends Node2D

var spectrum
var definition = 20  # Количество точек для отображения
var total_w = 800  # Общая ширина визуализации
var total_h = 30   # Максимальная высота полос (половина общей высоты)
var min_freq = 20.0  # Минимальная частота
var max_freq = 20000.0  # Максимальная частота

# Добавляем массив цветов для градиента
var colors = [
	Color(0.0, 0.5, 1.0),  # Синий
	Color(0.5, 0.0, 1.0),  # Фиолетовый
	Color(1.0, 0.0, 0.5),  # Розовый
	Color(1.0, 0.0, 0.0),  # Красный
	Color(1.0, 0.5, 0.0),  # Оранжевый
	Color(1.0, 1.0, 0.0),  # Желтый
	Color(0.0, 1.0, 0.0)   # Зеленый
]

func _ready():
	# Добавляем эффект спектрального анализа на основной аудио шину
	var bus_index = AudioServer.get_bus_index("Master")
	var effect = AudioEffectSpectrumAnalyzer.new()
	effect.buffer_length = 0.1
	effect.tap_back_pos = 0.1
	AudioServer.add_bus_effect(bus_index, effect, 0)
	
	# Получаем эффект после его создания
	spectrum = AudioServer.get_bus_effect_instance(bus_index, 0)

func _process(_delta):
	if spectrum:  # Проверяем, что эффект существует
		queue_redraw()

func _draw():
	if not spectrum:  # Не рисуем, если эффект не создан
		return
		
	var w = total_w / definition  # Ширина каждой полосы
	var spacing = 2  # Расстояние между полосами
	
	for i in range(definition):
		var t = float(i) / float(definition)
		var freq = lerp(min_freq, max_freq, t)
		var magnitude = spectrum.get_magnitude_for_frequency_range(freq, freq + 50).length()
		var height = clamp(magnitude * 2000, 0, total_h)  # Масштабируем значение
		
		# Вычисляем цвет для текущей полосы
		var color_index = int(t * (colors.size() - 1))
		var color_t = fmod(t * (colors.size() - 1), 1.0)
		var current_color = colors[color_index].lerp(
			colors[min(color_index + 1, colors.size() - 1)], 
			color_t
		)
		current_color.a = 0.7  # Устанавливаем прозрачность
		
		# Рисуем верхнюю и нижнюю части полосы
		var rect_pos = Vector2(i * (w + spacing), -height)
		var rect_size = Vector2(w, height * 2)  # Удваиваем высоту для симметрии
		draw_rect(Rect2(rect_pos, rect_size), current_color)
