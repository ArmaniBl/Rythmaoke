extends Node2D

var particles: Array = []
var lifetime = 1.0
var speed = 300.0
var colors = [
	Color(1, 0.2, 0.8),  # Розовый
	Color(0.8, 0.2, 1.0),  # Фиолетовый
	Color(0.2, 0.8, 1.0),  # Голубой
]

func _ready():
	# Создаем частицы
	for i in range(20):
		var angle = randf() * 2 * PI
		var velocity = Vector2(cos(angle), sin(angle)) * speed
		var color = colors[randi() % colors.size()]
		particles.append({
			"position": Vector2.ZERO,
			"velocity": velocity,
			"color": color,
			"time": 0
		})

func _process(delta):
	queue_redraw()
	for particle in particles:
		particle.time += delta
		particle.velocity.y += 400 * delta  # Гравитация
		particle.position += particle.velocity * delta
	
	if particles[0].time > lifetime:
		queue_free()

func _draw():
	for particle in particles:
		var alpha = 1.0 - (particle.time / lifetime)
		var color = particle.color
		color.a = alpha
		draw_circle(particle.position, 3, color) 