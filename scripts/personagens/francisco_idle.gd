extends Sprite2D

var original: Texture2D
var olhos_fechados: Texture2D
var base: Vector2
var tempo: float = 0.0
var proxima_piscada: float = 3.5
var piscando: float = 0.0

func _ready() -> void:
	original = texture
	olhos_fechados = load("res://assets/personagens/francisco/francisco-piscando.png")
	base = position

func _process(delta: float) -> void:
	tempo += delta
	# Respiração discreta, sem deslocar os pés.
	var respiracao := sin(tempo * 1.65) * 0.009
	scale.y = 1.0 + respiracao
	position.y = base.y - respiracao * 54.0
	proxima_piscada -= delta
	if proxima_piscada <= 0:
		texture = olhos_fechados
		piscando = 0.14
		proxima_piscada = randf_range(3.0, 5.5)
	if piscando > 0:
		piscando -= delta
		if piscando <= 0:
			texture = original
