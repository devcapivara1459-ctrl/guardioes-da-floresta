extends Node2D

@export var posicao_estante: Vector2 = Vector2(683, 171)
@export var posicao_chao: Vector2 = Vector2(683, 280)
@export var distancia_coleta: float = 64.0
var magia := 0.0
var tempo_magia := 0.0
var estado: String = "esperando"
var jogador: CharacterBody2D
var livro: Node2D
var aviso: Label
var botao_coleta: Button
var controles: CanvasLayer
var interface: CanvasLayer
var caixa: PanelContainer
var texto: Label
var indice: int = 0
var processava: bool = true
var falas: Array[String] = [
	"Ué… esse livro caiu sozinho? Eu nem encostei na estante!",
	"A capa está quentinha… Que árvore dourada bonita! Nunca vi um livro assim.",
	"Nunca vi esse livro por aqui… Vou falar com seu Francisco. Talvez ele saiba de onde veio."
]

func _ready() -> void:
	jogador = get_parent().get_node("jogador")
	if get_tree().has_meta("manuscrito_coletado"):
		estado = "coletado"
		return
	livro = Node2D.new()
	livro.position = posicao_estante
	livro.z_index = 1
	jogador.z_index = 3
	add_child(livro)
	var capa := Sprite2D.new()
	capa.name = "CapaArvoreDourada"
	capa.texture = preload("res://assets/objetos/livro-arvore-dourada.png")
	capa.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	capa.scale = Vector2.ONE * (56.0 / capa.texture.get_width())
	livro.add_child(capa)
	aviso = Label.new()
	aviso.text = "Pegar livro" if DisplayServer.is_touchscreen_available() else "E — Pegar"
	aviso.add_theme_font_size_override("font_size", 18)
	aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	aviso.add_theme_constant_override("outline_size", 6)
	aviso.position = posicao_chao + Vector2(-40, -48)
	aviso.z_index = 10
	aviso.hide()
	add_child(aviso)
	controles = CanvasLayer.new()
	controles.layer = 12
	add_child(controles)
	botao_coleta = Button.new()
	controles.add_child(botao_coleta)
	botao_coleta.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	botao_coleta.offset_left = -216
	botao_coleta.offset_right = -24
	botao_coleta.offset_top = -104
	botao_coleta.offset_bottom = -28
	botao_coleta.text = "Pegar livro"
	botao_coleta.add_theme_font_size_override("font_size", 24)
	botao_coleta.focus_mode = Control.FOCUS_NONE
	botao_coleta.pressed.connect(_pegar)
	botao_coleta.hide()
	if get_tree().has_meta("manuscrito_caiu"):
		estado = "no_chao"
		livro.position = posicao_chao
		livro.rotation = 0.04
		livro.scale = Vector2.ONE
	else:
		_cair()

func _process(_delta: float) -> void:
	tempo_magia += _delta
	queue_redraw()
	if estado == "coletado" or estado == "dialogo":
		return
	var pes := jogador.global_position + Vector2(15,33)
	var distancia := pes.distance_to(to_global(posicao_chao))
	if estado == "no_chao":
		aviso.visible = distancia <= distancia_coleta
		botao_coleta.visible = aviso.visible

func _cair() -> void:
	estado = "caindo"
	processava = jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.get_node("AnimatedSprite2D").stop()
	var animacao := create_tween()
	# The cover awakens briefly before the book tips off the shelf.
	animacao.tween_property(self, "magia", 1.0, 0.55).set_trans(Tween.TRANS_SINE)
	animacao.tween_interval(0.20)
	animacao.tween_property(livro, "rotation", 0.05, 0.24)
	animacao.tween_property(livro, "scale:y", 0.88, 0.18)
	animacao.tween_property(livro, "position:y", posicao_chao.y, 0.48).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	animacao.parallel().tween_property(livro, "scale:y", 1.0, 0.48)
	animacao.parallel().tween_property(livro, "rotation", 0.04, 0.48)
	animacao.tween_property(livro, "scale", Vector2(1.04, 0.94), 0.06)
	animacao.tween_property(livro, "scale", Vector2.ONE, 0.12)
	animacao.tween_property(self, "magia", 0.0, 0.35)
	animacao.tween_callback(func():
		estado = "no_chao"
		get_tree().set_meta("manuscrito_caiu", true)
		jogador.set_physics_process(processava)
	)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if estado == "no_chao" and aviso.visible and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		_pegar()
	elif estado == "dialogo" and event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		_avancar()

func _pegar() -> void:
	if estado != "no_chao" or not aviso.visible:
		return
	botao_coleta.hide()
	estado = "dialogo"
	get_tree().set_meta("manuscrito_coletado", true)
	livro.hide()
	aviso.hide()
	processava = jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.get_node("AnimatedSprite2D").stop()
	interface = CanvasLayer.new()
	interface.layer = 20
	add_child(interface)
	caixa = PanelContainer.new()
	interface.add_child(caixa)
	caixa.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caixa.offset_left = 28
	caixa.offset_right = -28
	caixa.offset_top = -210
	caixa.offset_bottom = -24
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("16121e")
	estilo.border_color = Color("f2e5c4")
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 22
	estilo.content_margin_right = 22
	estilo.content_margin_top = 16
	estilo.content_margin_bottom = 16
	caixa.add_theme_stylebox_override("panel", estilo)
	var coluna := VBoxContainer.new()
	caixa.add_child(coluna)
	var nome := Label.new()
	nome.text = "ANA"
	nome.add_theme_color_override("font_color", Color("f6cc78"))
	nome.add_theme_font_size_override("font_size", 22)
	coluna.add_child(nome)
	texto = Label.new()
	texto.text = falas[0]
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.add_theme_font_size_override("font_size", 22)
	coluna.add_child(texto)
	var botao := Button.new()
	botao.text = "Continuar" if DisplayServer.is_touchscreen_available() else "Continuar  [E / Enter / Espaço]"
	botao.custom_minimum_size.y = 56
	botao.focus_mode = Control.FOCUS_NONE
	botao.pressed.connect(_avancar)
	coluna.add_child(botao)

func _avancar() -> void:
	indice += 1
	if indice < falas.size():
		texto.text = falas[indice]
	else:
		interface.queue_free()
		estado = "coletado"
		jogador.set_physics_process(processava)


func _draw() -> void:
	if magia <= 0.0 or not is_instance_valid(livro) or not livro.visible:
		return
	var centro := livro.position
	for camada in range(4,0,-1):
		var pontos := PackedVector2Array()
		for i in range(24):
			var a := TAU*i/24.0
			pontos.append(centro+Vector2(cos(a)*(22+camada*4),sin(a)*(15+camada*3)))
		draw_colored_polygon(pontos,Color(0.52,0.88,0.35,magia*0.055))
	for i in range(18):
		var fase := fmod(tempo_magia*0.65+float(i)/18.0,1.0)
		var a := i*2.4+tempo_magia*0.6
		var ponto := centro+Vector2(cos(a)*(22+fase*13),sin(a)*14-fase*30)
		var alpha := sin(fase*PI)*magia
		draw_rect(Rect2(ponto.snapped(Vector2(2,2)),Vector2(2,2)),Color(0.95,0.86,0.40,alpha))
