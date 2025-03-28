extends Node

var selected_file_path: String = ""
var selected_audio_path: String = ""
var total_notes = 0
var missed_notes = 0
var missed_notes_indices = []  # Добавляем массив для отслеживания индексов промахов
var score = 0  # Добавляем переменную для счета
var difficulty = 1.0  # По умолчанию средняя сложность

# Добавляем словарь для хранения рекордов
var song_records = {}  # формат: {"путь_к_файлу": {"score": число, "difficulty": число}}

# Добавляем константу для пути к файлу сохранения
const SAVE_FILE = "user://song_records.save"

func _ready():
	load_records()

func save_records():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(song_records)

func load_records():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			song_records = file.get_var()

func update_record(path: String, new_score: int):
	if not song_records.has(path) or song_records[path].score < new_score:
		song_records[path] = {
			"score": new_score,
			"difficulty": difficulty
		}
		save_records()

func calculate_score() -> int:
	if total_notes == 0:
		return 0  # Возвращаем 0 если нет нот
	
	var hit_notes = total_notes - missed_notes  # Считаем количество успешных попаданий
	var accuracy = (float(hit_notes) / float(total_notes)) * 100  # Вычисляем процент
	return int(accuracy)  # Округляем до целого числа

func calculate_hit_points(combo: int) -> int:
	var base_points = 10
	if combo >= 5:
		# При комбо 5 и больше используем формулу: 10 * (1 + 0.1 * combo) * difficulty
		return int(base_points * (1 + 0.1 * combo) * difficulty)
	return int(base_points * difficulty)  # Применяем коэффициент сложности

func reset_score():
	total_notes = 0
	missed_notes = 0
	missed_notes_indices.clear()  # Очищаем массив индексов
	score = 0  # Сбрасываем счет

func set_difficulty(level: String):
	match level:
		"easy":
			difficulty = 0.5
		"normal":
			difficulty = 1.0
		"hard":
			difficulty = 1.5
