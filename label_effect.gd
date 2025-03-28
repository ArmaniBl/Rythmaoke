extends Label

var original_position: Vector2
var animation_tween: Tween

func _ready():
	original_position = position
	# Устанавливаем точку поворота в центр текста
	pivot_offset = size / 2

func set_text_with_effect(new_text: String):
	text = new_text
	
	# Отменяем предыдущую анимацию, если она есть
	if animation_tween:
		animation_tween.kill()
	
	# Создаем новую анимацию
	animation_tween = create_tween()
	
	# Масштаб относительно центра
	scale = Vector2(1.5, 1.5)
	animation_tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	# Только вертикальное движение
	position.y = original_position.y - 20
	position.x = original_position.x  # Фиксируем X позицию
	animation_tween.parallel().tween_property(self, "position:y", original_position.y, 0.2) 
