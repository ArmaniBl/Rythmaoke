extends Area2D

@export var speed = 400
@export var target_x = 214  # x-координата Bar

@onready var sprite = $Sprite2D
@onready var arrow_sprite = $ArrowSprite
var is_touching_bar = false

# Создаем текстуру круга программно
var circle_texture: Texture2D
var particles_scene = preload("res://ball_particles.tscn")

func _ready():
	# Подключаем сигналы столкновения
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Создаем круг программно
	var image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	
	# Рисуем круг
	for x in range(128):
		for y in range(128):
			var center = Vector2(64, 64)
			var pos = Vector2(x, y)
			var distance = pos.distance_to(center)
			if distance < 60:
				image.set_pixel(x, y, Color(1, 1, 1, 1))
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
	
	circle_texture = ImageTexture.create_from_image(image)

func setup(color: Color, texture: Texture2D):
	# Настраиваем основной спрайт (шар)
	sprite.texture = circle_texture
	sprite.scale = Vector2(0.35, 0.35)  # Размер шара оставляем
	sprite.modulate = color
	
	# Настраиваем спрайт стрелки
	arrow_sprite.texture = texture
	arrow_sprite.scale = Vector2(0.07, 0.07)  # Уменьшили размер стрелки
	arrow_sprite.modulate = Color.WHITE

func _process(delta):
	# Двигаем шар влево
	position.x -= speed * delta
	
	# Удаляем шар только если он ушел далеко за пределы экрана
	if position.x < -100:  # Даем запас в 100 пикселей за пределами экрана
		queue_free()

func _on_area_entered(area: Area2D):
	if area.get_parent().name == "Bar":
		is_touching_bar = true

func _on_area_exited(area: Area2D):
	if area.get_parent().name == "Bar":
		is_touching_bar = false

func destroy():
	# Создаем частицы
	var particles = particles_scene.instantiate()
	particles.modulate = sprite.modulate
	particles.position = position
	get_parent().add_child(particles)
	particles.emitting = true
	
	# Удаляем шар
	queue_free()
