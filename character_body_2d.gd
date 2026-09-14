extends CharacterBody2D

@export var velocidade: float = 180.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_direcao: String = "baixo"


func _ready() -> void:
	sprite.animation = ultima_direcao
	sprite.frame = 1


func _physics_process(_delta: float) -> void:
	var direcao := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direcao * velocidade
	move_and_slide()

	if direcao != Vector2.ZERO:
		if abs(direcao.x) > abs(direcao.y):
			ultima_direcao = "direita" if direcao.x > 0 else "esquerda"
		else:
			ultima_direcao = "baixo" if direcao.y > 0 else "cima"

		sprite.play(ultima_direcao)
	else:
		sprite.stop()
		sprite.animation = ultima_direcao
		sprite.frame = 1
