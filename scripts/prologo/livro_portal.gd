extends Node2D

@export var posicao_portal: Vector2 = Vector2(576, 180)
@export var tamanho_portal: Vector2 = Vector2(148, 150)

var jogador: CharacterBody2D
var estado := "carregado"
var ui: CanvasLayer
var acao: Button
var painel: PanelContainer
var legenda: Label
var sim: Button
var nao: Button
var livro: Sprite2D
var portal: Sprite2D
var material_portal: ShaderMaterial
var arte_portal: Texture2D
var tempo := 0.0
var abertura := 0.0
var fala_indice := 0
var falas := ["Voz desconhecida: Por favor… alguém consegue me ouvir? Preciso de ajuda!", "Ana: Essa voz… está vindo de dentro do portal! Tem alguém lá?"]

func _ready() -> void:
	jogador = get_parent().get_node("sala_favorita/jogador")
	# Coordinates are global because the original room has nested offsets.
	global_position = Vector2.ZERO
	z_index = 2
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	livro = Sprite2D.new()
	livro.texture = preload("res://assets/objetos/livro-arvore-dourada.png")
	livro.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	livro.position = Vector2(598, 325)
	livro.scale = Vector2.ONE * (44.0 / livro.texture.get_width())
	add_child(livro)
	livro.hide()
	ui = CanvasLayer.new()
	ui.layer = 22
	add_child(ui)
	acao = Button.new()
	ui.add_child(acao)
	acao.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	acao.offset_left = -310
	acao.offset_right = -24
	acao.offset_top = -108
	acao.offset_bottom = -28
	acao.add_theme_font_size_override("font_size", 22)
	acao.pressed.connect(_interagir)
	acao.hide()
	painel = PanelContainer.new()
	ui.add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_left = 28
	painel.offset_right = -28
	painel.offset_top = -220
	painel.offset_bottom = -24
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("161c20")
	estilo.border_color = Color("d6b16b")
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 24
	estilo.content_margin_right = 24
	estilo.content_margin_top = 18
	estilo.content_margin_bottom = 18
	painel.add_theme_stylebox_override("panel", estilo)
	var coluna := VBoxContainer.new()
	painel.add_child(coluna)
	legenda = Label.new()
	legenda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legenda.size_flags_vertical = Control.SIZE_EXPAND_FILL
	legenda.add_theme_font_size_override("font_size", 24)
	coluna.add_child(legenda)
	var linha := HBoxContainer.new()
	coluna.add_child(linha)
	sim = Button.new()
	sim.text = "Sim [E]"
	sim.custom_minimum_size = Vector2(180, 60)
	sim.pressed.connect(_confirmar)
	linha.add_child(sim)
	nao = Button.new()
	nao.text = "Agora não [Esc]"
	nao.custom_minimum_size = Vector2(220, 60)
	nao.pressed.connect(_cancelar)
	linha.add_child(nao)
	painel.hide()
	arte_portal = preload("res://assets/objetos/portal-floresta.png")
	portal = Sprite2D.new()
	portal.texture = arte_portal
	portal.position = posicao_portal
	portal.scale = tamanho_portal / arte_portal.get_size()
	material_portal = ShaderMaterial.new()
	material_portal.shader = preload("res://shaders/portal_revelacao.gdshader")
	portal.material = material_portal
	add_child(portal)

	if get_tree().has_meta("portal_despertou"):
		estado = "concluido"
		abertura = 1.0
	elif get_tree().has_meta("livro_na_mesa"):
		estado = "mesa"
		livro.show()

func _perto() -> bool:
	var pes := jogador.global_position + Vector2(15, 33.5)
	return Rect2(470, 300, 220, 175).has_point(pes)

func _process(delta: float) -> void:
	tempo += delta
	material_portal.set_shader_parameter("revelar", smoothstep(0.28, 0.88, abertura))
	acao.visible = (estado in ["carregado", "mesa"] and _perto() or estado == "concluido" and (jogador.global_position + Vector2(15,33.5)).distance_to(posicao_portal + Vector2(0,75)) < 115) and jogador.is_physics_processing() and get_tree().has_meta("manuscrito_coletado")
	acao.text = "Entrar no portal [E]" if estado == "concluido" else ("Colocar livro na mesa [E]" if estado == "carregado" else "Abrir livro [E]")
	queue_redraw()

func _interagir() -> void:
	if not acao.visible:
		return
	if estado == "concluido":
		acao.hide()
		var transicao := CanvasLayer.new()
		transicao.set_script(preload("res://scripts/sistemas/transicao_cena.gd"))
		get_tree().root.add_child(transicao)
		transicao.viajar("res://cenas/floresta/floresta.tscn",Vector2(250,490),jogador)
		return
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.get_node("AnimatedSprite2D").stop()
	acao.hide()
	legenda.text = "Colocar o livro na mesa?" if estado == "carregado" else "Abrir o livro?"
	sim.text = "Sim [E]"
	nao.show()
	painel.show()

func _cancelar() -> void:
	if estado == "voz":
		return
	painel.hide()
	jogador.set_physics_process(true)

func _confirmar() -> void:
	if not painel.visible:
		return
	if estado == "voz":
		fala_indice += 1
		if fala_indice < falas.size():
			legenda.text = falas[fala_indice]
		else:
			painel.hide()
			estado = "concluido"
			jogador.set_physics_process(true)
		return
	if estado == "carregado":
		estado = "mesa"
		get_tree().set_meta("livro_na_mesa", true)
		livro.show()
		legenda.text = "Ana: Pronto… Vou abrir o livro?"
		return
	if estado == "mesa":
		estado = "abrindo"
		painel.hide()
		livro.hide()
		var surgir := create_tween()
		surgir.tween_property(self, "abertura", 1.0, 3.6).set_trans(Tween.TRANS_LINEAR)
		await surgir.finished
		get_tree().set_meta("portal_despertou", true)
		estado = "voz"
		fala_indice = 0
		legenda.text = falas[0]
		sim.text = "Continuar [E]"
		nao.hide()
		painel.show()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
			if painel.visible:
				_confirmar()
			elif acao.visible:
				_interagir()
			else:
				return
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and painel.visible and estado != "voz":
			_cancelar()
			get_viewport().set_input_as_handled()

func _draw() -> void:
	if estado in ["abrindo", "voz", "concluido"]:
		# Open book: two cream pages, brown binding and golden ink.
		draw_rect(Rect2(571, 310, 54, 29), Color("38231f"))
		draw_colored_polygon(PackedVector2Array([Vector2(573,309),Vector2(596,312),Vector2(596,337),Vector2(573,333)]), Color("e5c995"))
		draw_colored_polygon(PackedVector2Array([Vector2(599,312),Vector2(623,309),Vector2(623,333),Vector2(599,337)]), Color("f4dfb0"))
		for y in [316, 321, 326]:
			draw_rect(Rect2(577,y,15,2), Color("a87b3c"))
			draw_rect(Rect2(603,y,15,2), Color("a87b3c"))
	if abertura <= 0:
		return
	var centro := posicao_portal
	# Dark inset stays behind the wooden frame, giving the wall opening depth.
	var encaixe := PackedVector2Array()
	for i in range(40):
		var angulo := TAU * i / 40.0
		encaixe.append(centro + Vector2(cos(angulo)*tamanho_portal.x*0.32, sin(angulo)*tamanho_portal.y*0.43 + 5).snapped(Vector2(2,2)))
	draw_colored_polygon(encaixe, Color(0.035,0.025,0.025,smoothstep(0.25,0.85,abertura)*0.85))
	var energia := sin(clampf(abertura / 0.95, 0, 1) * PI)
	# Soft local light gathers before the wooden arch is revealed.
	for camada in range(5, 0, -1):
		var halo := PackedVector2Array()
		for i in range(32):
			var angulo := TAU * i / 32.0
			halo.append(centro + Vector2(cos(angulo)*(29+camada*5), sin(angulo)*(49+camada*5)))
		draw_colored_polygon(halo, Color(0.40,0.88,0.42,energia*0.035))
	if estado == "abrindo":
		# Staggered motes travel from the pages to the wall, then fade away.
		for i in range(26):
			var inicio := float(i) * 0.014
			var t := (abertura - inicio) / 0.39
			if t <= 0 or t >= 1:
				continue
			var origem := Vector2(597+(i%5-2)*4,319)
			var destino := centro + Vector2(sin(i*2.4)*31, cos(i*1.7)*42)
			var pos := origem.lerp(destino, t)
			pos.x += sin(t*PI)*sin(i*1.3)*22
			var alpha := sin(t*PI)*0.85
			draw_rect(Rect2(pos.snapped(Vector2(2,2)),Vector2(3,3)),Color(0.9,0.95,0.5,alpha))
		var brilho_livro := sin(clampf(abertura/0.65,0,1)*PI)*0.16
		draw_rect(Rect2(572,309,52,29),Color(0.91,1.0,0.6,brilho_livro))
	var intensidade := smoothstep(0.65,1.0,abertura)
	for i in range(12):
		var a := i * 2.4 + tempo * 0.35
		var ponto := centro + Vector2(cos(a)*25, sin(a*0.7)*48)
		var luz := (0.2 + 0.4 * (sin(tempo*2+i)+1)*0.5)*intensidade
		draw_rect(Rect2(ponto.snapped(Vector2(2,2)), Vector2(2,2)), Color(0.94,0.88,0.47,luz))
