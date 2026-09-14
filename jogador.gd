extends CharacterBody2D

@export var velocidade: float = 180.0
@export var movimento_lateral: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_direcao: String = "baixo"
var material_caminhada: ShaderMaterial
const POSICAO_VISUAL := Vector2(15, -18.5)


func _ready() -> void:
	z_index = 3
	preload("res://ana_visual.gd").aplicar(sprite)
	material_caminhada = ShaderMaterial.new()
	material_caminhada.shader = preload("res://ana_caminhada.gdshader")
	sprite.material = material_caminhada
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
	_atualizar_articulacao()


func _process(_delta: float) -> void:
	_atualizar_articulacao()


func _atualizar_articulacao() -> void:
	var textura := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame) as AtlasTexture
	if textura == null:
		return
	var dimensoes := textura.atlas.get_size()
	material_caminhada.set_shader_parameter("quadro", Vector4(textura.region.position.x / dimensoes.x, textura.region.position.y / dimensoes.y, textura.region.size.x / dimensoes.x, textura.region.size.y / dimensoes.y))
	var andando := is_physics_processing() and sprite.is_playing() and get_real_velocity().length() > 1.0
	var fase := (float(sprite.frame) + sprite.get_frame_progress()) * TAU / 4.0
	material_caminhada.set_shader_parameter("fase", fase)
	material_caminhada.set_shader_parameter("intensidade", 1.0 if andando else 0.0)
	material_caminhada.set_shader_parameter("perfil", ultima_direcao in ["direita", "esquerda"])
	material_caminhada.set_shader_parameter("lado", -1.0 if ultima_direcao == "esquerda" else 1.0)
	sprite.position = POSICAO_VISUAL
	if andando:
		sprite.position.y -= abs(sin(fase)) * 1.2


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
