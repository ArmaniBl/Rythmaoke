extends Node

const MAX_SEQUENCE_LENGTH = 4
const MIN_SIMPLE_SEQUENCES = 2  # Минимальное количество простых последовательностей после сложной
const MIN_PAUSE_MULTIPLIER = 0.6  # Увеличили с 0.5 до 0.6
const MAX_PAUSE_MULTIPLIER = 1.0  # Увеличили с 0.8 до 1.0

func analyze_audio(audio_stream: AudioStream) -> Dictionary:
	var data = {
		"signals": [],
		"times": [],
		"centroids": [],
		"rms_values": [],
		"beats": [],
		"tempo": 120.0
	}
	
	var length = audio_stream.get_length()
	var bpm = determine_tempo(length)
	data.tempo = bpm
	var base_interval = (60.0 / bpm) * 0.9
	var current_time = 3.0
	var simple_sequences_required = 0
	
	# Определяем параметры в зависимости от сложности
	var max_sequence_length = MAX_SEQUENCE_LENGTH
	var min_sequence_interval = 0.0
	
	match Global.difficulty:
		0.5:  # Легкая
			min_sequence_interval = 1.5
			max_sequence_length = 2
		1.0:  # Средняя
			min_sequence_interval = 1.0
			max_sequence_length = 3
		1.5:  # Сложная
			min_sequence_interval = 0.5
			max_sequence_length = MAX_SEQUENCE_LENGTH
	
	var last_sequence_time = -min_sequence_interval
	var filtered_signals = []
	var filtered_times = []
	
	while current_time < length:
		var sequence_length = 1
		
		if simple_sequences_required <= 0:
			# Ограничиваем длину последовательности в зависимости от сложности
			sequence_length = randi() % max_sequence_length + 1
			if sequence_length > 2:
				simple_sequences_required = MIN_SIMPLE_SEQUENCES + (sequence_length - 2)
		else:
			sequence_length = randi() % 2 + 1
			simple_sequences_required -= 1
		
		# Проверяем интервал между последовательностями
		if current_time - last_sequence_time >= min_sequence_interval:
			var sequence_interval = base_interval / sequence_length
			var sequence_start_time = current_time
			
			# Генерируем всю последовательность
			for i in range(sequence_length):
				var directions = ["up", "down", "left", "right"]
				if data.signals.size() > 0:
					var last_direction = data.signals[data.signals.size() - 1]
					directions.erase(last_direction)
				
				var direction = directions[randi() % directions.size()]
				filtered_signals.append(direction)
				filtered_times.append(current_time)
				
				data.signals.append(direction)
				data.times.append(current_time)
				data.rms_values.append(1.0)
				data.centroids.append(1000.0)
				data.beats.append(current_time)
				
				current_time += sequence_interval
			
			last_sequence_time = sequence_start_time
		
		var pause_multiplier = MIN_PAUSE_MULTIPLIER + (sequence_length / MAX_SEQUENCE_LENGTH) * (MAX_PAUSE_MULTIPLIER - MIN_PAUSE_MULTIPLIER)
		if sequence_length > 2:
			pause_multiplier *= 1.1
		
		var min_pause = base_interval * pause_multiplier
		var max_pause = min_pause * 1.1
		var pause = randf_range(min_pause, max_pause)
		current_time += pause
	
	return {
		"signals": filtered_signals,
		"times": filtered_times,
		"centroids": data.centroids,
		"rms_values": data.rms_values,
		"beats": data.beats,
		"tempo": data.tempo
	}

func calculate_rms(buffer: PackedFloat32Array, start: int, length: int) -> float:
	var sum = 0.0
	var end = min(start + length, buffer.size())
	
	for i in range(start, end):
		sum += buffer[i] * buffer[i]
	
	return sqrt(sum / float(end - start))

func get_frequencies(buffer: PackedFloat32Array, start: int, length: int, sample_rate: float) -> Array:
	# Упрощенный FFT анализ
	# Возвращает массив частот
	# ...
	return []

func determine_direction(frequencies: Array) -> String:
	# Определяем направление на основе частотного анализа
	# Низкие частоты -> "down"
	# Высокие частоты -> "up"
	# Средние частоты -> "left" или "right"
	# ...
	return "up"  # Заглушка

func get_centroid(frequencies: Array) -> float:
	# Вычисляем спектральный центроид
	# ...
	return 0.0

func determine_tempo(length: float) -> float:
	# Ещё немного уменьшили темпы
	if length < 120.0:  # Меньше 2 минут
		return randf_range(120.0, 150.0)  # Уменьшили темп
	elif length < 240.0:  # 2-4 минуты
		return randf_range(100.0, 130.0)  # Уменьшили темп
	else:  # Больше 4 минут
		return randf_range(80.0, 110.0)  # Уменьшили темп
