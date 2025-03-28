extends Node

var current_language = "ru"

var translations = {
	"ru": {
		"settings": "Настройки",
		"back": "Назад",
		"language": "Язык",
		"volume": "Громкость",
		"difficulty": "Сложность:",
		"easy": "Легкая",
		"normal": "Средняя",
		"hard": "Сложная",
		"select_file": "Выбрать файл",
		"song_history": "История песен:",
		"record": "Рекорд: %d (%s)",
		"pause": "ПАУЗА",
		"restart": "Начать заново",
		"quit": "Выйти в меню",
		"perfect": "Отлично! (+%d)",
		"perfect_combo": "Отлично! x%d (+%d)",
		"miss": "Промах!",
		"score": "Счёт: %d",
		"volume_label": "Громкость",
		"total_notes": "Всего нот",
		"missed_notes": "Пропущено",
		"accuracy": "Точность",
		"final_score": "Итоговый счёт",
		"new_game": "Новая игра",
		"fullscreen": "Полный экран",
		"display": "Экран",
		"quit_game": "Выход"
	},
	"en": {
		"settings": "Settings",
		"back": "Back",
		"language": "Language",
		"volume": "Volume",
		"difficulty": "Difficulty:",
		"easy": "Easy",
		"normal": "Normal",
		"hard": "Hard",
		"select_file": "Select File",
		"song_history": "Song History:",
		"record": "Record: %d (%s)",
		"pause": "PAUSE",
		"restart": "Restart",
		"quit": "Quit to Menu",
		"perfect": "Perfect! (+%d)",
		"perfect_combo": "Perfect! x%d (+%d)",
		"miss": "Miss!",
		"score": "Score: %d",
		"volume_label": "Volume",
		"total_notes": "Total Notes",
		"missed_notes": "Missed Notes",
		"accuracy": "Accuracy",
		"final_score": "Final Score",
		"new_game": "New Game",
		"fullscreen": "Fullscreen",
		"display": "Display",
		"quit_game": "Quit Game"
	}
}

func _ready():
	load_settings()

func translate(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	return key

func set_language(lang: String):
	if translations.has(lang):
		current_language = lang
		save_settings()

func save_settings():
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_var({"language": current_language})

func load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var file = FileAccess.open("user://settings.save", FileAccess.READ)
		if file:
			var data = file.get_var()
			if data.has("language"):
				current_language = data.language

func set_fullscreen(value: bool):
	pass 