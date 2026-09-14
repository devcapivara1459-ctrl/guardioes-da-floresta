extends Node2D

@export_enum("Entrada", "Trilha", "Sumaúma") var zona: int = 0

var jogador: CharacterBody2D
var botao: Button
var caixa: PanelContainer
var texto: Label
var etapa := 0
var falando := false
var relogio := 0.0
var espirito: Sprite2D
var material_espirito: ShaderMaterial
var retrato: TextureRect
var destino_interacao := ""
var viajando := false
var falas_atuais: Array[String] = []
var conclusao := ""
const ENTRADA := Vector2(165, 520)
const ESPIRITO := Vector2(710, 490)
const GUIA := [Vector2(870,775),Vector2(1065,835),Vector2(1220,935),Vector2(1390,910),Vector2(1575,900),Vector2(1810,845),Vector2(1975,715),Vector2(2100,595)]

func _ready() -> void:
	jogador = $jogador
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var camera := jogador.get_node("CameraSuave") as Camera2D
	camera.limit_right = 1152
	camera.limit_bottom = 648
	camera.zoom = Vector2.ONE
	camera.reset_smoothing()
	var portal := Sprite2D.new()
	portal.texture = preload("res://ana-godot/portal-floresta.png")
	portal.position = Vector2(165,460)
	portal.scale = Vector2.ONE * 0.10
	portal.visible = zona == 0
	add_child(portal)
	espirito = Sprite2D.new()
	espirito.texture = preload("res://ana-godot/espirito-sumauma.png")
	espirito.scale = Vector2.ONE * (150.0 / espirito.texture.get_height())
	espirito.position = ESPIRITO - Vector2(0,55)
	material_espirito = ShaderMaterial.new()
	material_espirito.shader = preload("res://espirito_vivo.gdshader")
	espirito.material = material_espirito
	espirito.z_index = 2
	espirito.visible = zona == 2
	add_child(espirito)
	var corpo_espirito := StaticBody2D.new()
	corpo_espirito.position = ESPIRITO + Vector2(0,15)
	var forma := CollisionShape2D.new()
	var retangulo := RectangleShape2D.new()
	retangulo.size = Vector2(38,18)
	forma.shape = retangulo
	corpo_espirito.add_child(forma)
	if zona == 2:
		add_child(corpo_espirito)
	else:
		corpo_espirito.free()
	var ui := CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	var titulo := Label.new()
	titulo.text = ["PRÓLOGO • A entrada", "PRÓLOGO • O caminho incerto", "PRÓLOGO • A Sumaúma"][zona]
	titulo.position = Vector2(24,20)
	titulo.add_theme_font_size_override("font_size",22)
	titulo.add_theme_color_override("font_outline_color",Color("102d24"))
	titulo.add_theme_constant_override("outline_size",6)
	ui.add_child(titulo)
	botao = Button.new()
	ui.add_child(botao)
	botao.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	botao.offset_left = -290
	botao.offset_right = -24
	botao.offset_top = -105
	botao.offset_bottom = -25
	botao.add_theme_font_size_override("font_size",22)
	botao.pressed.connect(_interagir)
	caixa = PanelContainer.new()
	ui.add_child(caixa)
	caixa.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caixa.offset_left = 28
	caixa.offset_right = -28
	caixa.offset_top = -210
	caixa.offset_bottom = -24
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("132821")
	estilo.border_color = Color("c5a76b")
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 24
	estilo.content_margin_right = 24
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	caixa.add_theme_stylebox_override("panel",estilo)
	var coluna := VBoxContainer.new()
	caixa.add_child(coluna)
	texto = Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.add_theme_font_size_override("font_size",24)
	coluna.add_child(texto)
	var continuar := Button.new()
	continuar.text = "Continuar [E]"
	continuar.custom_minimum_size.y = 56
	continuar.pressed.connect(_avancar)
	coluna.add_child(continuar)
	caixa.hide()
	if zona == 0 and not get_tree().has_meta("floresta_chegada_vista"):
		call_deferred("_introducao")

func _introducao() -> void:
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree() and not viajando:
		_dialogo(["Ana: Onde eu vim parar? Não conheço este lugar…", "Ana: Mas sinto alguma coisa me chamando. Como se alguém estivesse esperando por mim."], "floresta_chegada_vista")

func _process(delta: float) -> void:
	relogio += delta
	var pes := jogador.global_position + Vector2(15,33.5)
	espirito.position.y = ESPIRITO.y - 55 + sin(relogio * 1.4) * 1.5
	material_espirito.set_shader_parameter("tempo", relogio)
	# The source art faces left; mirror it to follow Ana's horizontal direction.
	if jogador.ultima_direcao in ["direita", "esquerda"]:
		espirito.flip_h = jogador.ultima_direcao == "direita"
	espirito.modulate.a = clampf(1.0-(pes.distance_to(ESPIRITO)-170.0)/350.0,0.0,1.0)
	destino_interacao = ""
	if zona == 0 and pes.distance_to(ENTRADA)<95:
		destino_interacao = "biblioteca"
	elif zona == 2 and pes.distance_to(ESPIRITO)<125:
		destino_interacao = "espirito"
	elif pes.x>990 and zona<2:
		destino_interacao = "avancar"
	elif pes.x<120 and zona>0:
		destino_interacao = "voltar"
	elif zona == 1 and pes.distance_to(Vector2(430,470))<80:
		destino_interacao = "desvio"
	botao.visible = not falando and not viajando and jogador.is_physics_processing() and destino_interacao != ""
	var rotulos := {"biblioteca":"Voltar à biblioteca [E]", "espirito":"Falar com o espírito [E]", "avancar":"Seguir o chamado [E]", "voltar":"Voltar pela trilha [E]", "desvio":"Examinar passagem [E]"}
	botao.text = rotulos.get(destino_interacao, "")
	if zona == 1 and pes.x>550 and not falando and not viajando and jogador.is_physics_processing() and not get_tree().has_meta("floresta_bifurcacao"):
		_dialogo(["Ana: Tem uma passagem entre as raízes… mas está bloqueada.", "Ana: Sinto o chamado vindo do outro lado. As luzinhas estão seguindo para a direita…"],"floresta_bifurcacao")
	queue_redraw()

func _viajar_zona(destino: String, chegada: Vector2) -> void:
	viajando = true
	botao.hide()
	var transicao := CanvasLayer.new()
	transicao.set_script(preload("res://transicao_cena.gd"))
	get_tree().root.add_child(transicao)
	await transicao.viajar(destino,chegada,jogador)
	if is_inside_tree():
		viajando = false

func _dialogo(falas: Array[String], flag: String) -> void:
	falas_atuais = falas
	conclusao = flag
	etapa = 0
	falando = true
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.get_node("AnimatedSprite2D").stop()
	texto.text = falas[0]
	caixa.show()
	botao.hide()

func _avancar() -> void:
	if not falando:
		return
	etapa += 1
	if etapa < falas_atuais.size():
		texto.text = falas_atuais[etapa]
		return
	if conclusao != "":
		get_tree().set_meta(conclusao,true)
	falando = false
	caixa.hide()
	jogador.set_physics_process(true)

func _interagir() -> void:
	if not botao.visible or viajando:
		return
	if destino_interacao == "biblioteca":
		_viajar_zona("res://biblioteca.tscn",Vector2(690,265))
	elif destino_interacao == "avancar":
		_viajar_zona("res://floresta_trilha.tscn" if zona == 0 else "res://floresta_sumauma.tscn",Vector2(175,490))
	elif destino_interacao == "voltar":
		_viajar_zona("res://floresta.tscn" if zona == 1 else "res://floresta_trilha.tscn",Vector2(925,490))
	elif destino_interacao == "desvio":
		_dialogo(["Ana: Essas raízes fecharam a passagem. Não consigo seguir por aqui.", "Ana: Ainda sinto aquele chamado… Vou tentar o caminho da direita."],"floresta_desvio")
	else:
		jogador.ultima_direcao = "direita" if jogador.global_position.x < ESPIRITO.x else "esquerda"
		jogador.get_node("AnimatedSprite2D").animation = jogador.ultima_direcao
		jogador.get_node("AnimatedSprite2D").frame = 1
		if get_tree().has_meta("sumauma_encontro"):
			_dialogo(["Espírito da Sumaúma: Cada raiz guarda uma virtude. Nossa jornada começará pela Prudência.", "Ana: Vou descobrir o que está enfraquecendo a floresta."],"")
		else:
			_dialogo([
				"Espírito: Finalmente… alguém ouviu.",
				"Ana: Era você que estava me chamando? Quem é você?",
				"Espírito: Sou uma manifestação do Espírito da Sumaúma. É através de mim que ela consegue falar com você.",
				"Ana: Você pediu ajuda… O que aconteceu?",
				"Espírito da Sumaúma: A Sumaúma está enfraquecendo. Sinto sua força desaparecer, mas ainda não sei o que está causando isso.",
				"Espírito da Sumaúma: Ela possui sete raízes espirituais. Cada uma alcança uma região diferente da floresta.",
				"Espírito da Sumaúma: Prudência, Fortaleza, Justiça, Caridade, Esperança, Temperança e Fé. As sete virtudes do livro que chamou você.",
				"Ana: E alguma coisa está machucando essas raízes?",
				"Espírito da Sumaúma: Algo está corrompendo o que as mantém vivas. Consigo sentir a dor, mas não enxergar sua origem.",
				"Ana: Eu não sei se consigo resolver isso… mas posso tentar descobrir.",
				"Espírito da Sumaúma: Não precisa ter todas as respostas agora. Podemos começar pela raiz da Prudência."
			],"sumauma_encontro")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
		if falando:
			_avancar()
		elif botao.visible:
			_interagir()
		else:
			return
		get_viewport().set_input_as_handled()

func _draw() -> void:
	if zona == 2:
		return
	for i in range(14):
		var fase := fmod(relogio*0.08+float(i)/14.0,1.0)
		var pos := Vector2(400+fase*660,480+sin(relogio+i*1.7)*18)
		var alpha := sin(fase*PI)*0.75
		draw_rect(Rect2(pos-Vector2(2,2),Vector2(6,6)),Color(0.53,0.93,0.38,alpha*0.16))
		draw_rect(Rect2(pos,Vector2(2,2)),Color(0.90,0.96,0.58,alpha))
