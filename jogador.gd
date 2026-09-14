extends CharacterBody2D

@export var velocidade: float = 180.0
@export var movimento_lateral: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_direcao: String = "baixo"


func _ready() -> void:
	z_index = 3
	preload("res://ana_visual.gd").aplicar(sprite)
	sprite.material = null
	var camera := Camera2D.new()
	camera.name = "CameraSuave"
	camera.set_script(preload("res://camera_suave.gd"))
	add_child(camera)
	if get_tree().has_meta("chegada_porta"):
		global_position = get_tree().get_meta("chegada_porta")
		get_tree().remove_meta("chegada_porta")
	if movimento_lateral and ultima_direcao in ["cima", "baixo"]:
		ultima_direcao = "direita"
	sprite.animation = ultima_direcao
	sprite.frame = 1


func _physics_process(_delta: float) -> void:
	var direcao := Vector2(
		float(Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D)) - float(Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S)) - float(Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W))
	)
	if movimento_lateral:
		direcao.y = 0.0
	direcao = direcao.limit_length()

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
