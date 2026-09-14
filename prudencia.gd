extends "res://floresta.gd"

var progresso
var fase := 0
var vistos: Dictionary = {}
var em_batalha := false
var encontro_pendente := false
var curupira: Sprite2D
var escolhas: HBoxContainer
var barra_acoes: HBoxContainer
var cabecalho: Label
var aviso_save: Label
var sombra_tempo := 0.0
var revelando := 0.0
var animal_tempo := 0.0
var caminho_revelado := false

func _ready() -> void:
	get_tree().set_meta("floresta_chegada_vista",true)
	super._ready()
	progresso = get_node("/root/Progresso")
	fase = int(progresso.dados.etapa)
	for filho in get_children():
		if filho is Sprite2D and filho.name != "Cenario": filho.hide()
	curupira = preload("res://batalhas/curupira_sprite.gd").new()
	curupira.position = Vector2(850,451)
	curupira.z_index = 2
	add_child(curupira)
	curupira.hide()
	var camada := botao.get_parent() as CanvasLayer
	for filho in camada.get_children():
		if filho is Label: filho.hide()
	cabecalho = Label.new()
	cabecalho.position = Vector2(24,20)
	cabecalho.add_theme_font_size_override("font_size",24)
	cabecalho.add_theme_constant_override("outline_size",5)
	cabecalho.add_theme_color_override("font_outline_color",Color("102319"))
	camada.add_child(cabecalho)
	aviso_save = Label.new()
	aviso_save.position = Vector2(24,180)
	camada.add_child(aviso_save)
	barra_acoes = HBoxContainer.new()
	barra_acoes.position = Vector2(715,20)
	camada.add_child(barra_acoes)
	_botao_capitulo(barra_acoes,"Observar [O]",_observar)
	_botao_capitulo(barra_acoes,"Livro [L]",_livro)
	escolhas = HBoxContainer.new()
	camada.add_child(escolhas)
	escolhas.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	escolhas.offset_left = 24
	escolhas.offset_right = -24
	escolhas.offset_top = -86
	escolhas.offset_bottom = -24
	_botao_capitulo(escolhas,"Atalho entre os troncos",func(): _escolher(false))
	_botao_capitulo(escolhas,"Trilha junto à raiz",func(): _escolher(true))
	_botao_capitulo(escolhas,"Observar primeiro",_observar)
	_aplicar_fase()
	if fase == 0:
		_dialogo(["CAPÍTULO 1 — PRUDÊNCIA", "Ana: A raiz segue para dentro da mata. Vou descobrir o que a enfraqueceu."],"")

func _botao_capitulo(pai: Control, rotulo: String, acao: Callable) -> void:
	var b := Button.new()
	b.text = rotulo
	b.custom_minimum_size = Vector2(150,44)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size",18)
	b.pressed.connect(acao)
	pai.add_child(b)

func _aplicar_fase() -> void:
	vistos.clear()
	cabecalho.text = ["CAPÍTULO 1 • PRUDÊNCIA — Os sinais","PRUDÊNCIA — Um caminho incerto","PRUDÊNCIA — O guardião ferido","PRUDÊNCIA — O que fica depois"][clampi(fase,0,3)]
	$Cenario.modulate = [Color("b5cabd"),Color("9aacb0"),Color("a6b2a3"),Color.WHITE][clampi(fase,0,3)]
	curupira.visible = fase == 3 and progresso.dados.curupira_status == "aliado"
	curupira.position = Vector2(850,451)
	curupira.rotation = 0
	escolhas.hide()
	_salvar()

func _salvar() -> void:
	progresso.dados.etapa = fase
	aviso_save.text = "" if progresso.salvar("res://prudencia.tscn",jogador.position) else progresso.erro

func _process(delta: float) -> void:
	if not is_instance_valid(curupira): return
	relogio += delta
	if em_batalha:
		botao.hide()
		barra_acoes.hide()
		escolhas.hide()
		queue_redraw()
		return
	barra_acoes.visible = not falando and not viajando
	var escolhas_antes := escolhas.visible
	escolhas.visible = fase == 1 and jogador.position.x > 480 and not falando
	if escolhas.visible and not escolhas_antes: escolhas.get_child(0).grab_focus()
	botao.visible = not falando and not viajando and not escolhas.visible
	if fase == 0: botao.text = "Seguir a trilha [E]" if jogador.position.x > 950 else ""
	elif fase == 1: botao.text = ""
	elif fase == 2: botao.text = "Aproximar-se [E]" if jogador.position.x > 600 else ""
	else: botao.text = "Continuar pela floresta [E]" if jogador.position.x > 950 else ""
	botao.visible = botao.visible and not botao.text.is_empty()
	if falando: return
	if fase == 0:
		if jogador.position.x > 330 and not vistos.has("rastros"):
			vistos.rastros = true
			_dialogo(["Ana: Essas pegadas… os dedos apontam para o lado de onde eu vim."],"")
		elif jogador.position.x > 560 and not vistos.has("som"):
			vistos.som = true
			_som()
			animal_tempo = 1.0
		elif jogador.position.x > 790 and not vistos.has("vulto"):
			vistos.vulto = true
			sombra_tempo = 0.75
	elif fase == 2:
		if jogador.position.x > 350 and not vistos.has("silhueta"):
			vistos.silhueta = true
			sombra_tempo = 1.1
			_som()
		if jogador.position.x > 680 and not vistos.has("encontro"):
			_iniciar_encontro()
			return
	sombra_tempo = maxf(0,sombra_tempo-delta)
	animal_tempo = maxf(0,animal_tempo-delta)
	revelando = maxf(0,revelando-delta)
	if fase < 3:
		curupira.visible = sombra_tempo > 0
		curupira.position = Vector2(840+sombra_tempo*35,400)
		curupira.modulate = Color(0.20,0.24,0.20,0.65)
	queue_redraw()

func _observar() -> void:
	if falando or em_batalha or viajando: return
	if progresso.tem_bencao("passos_curupira"):
		caminho_revelado = true
		revelando = 8.0
		_dialogo(["Os rastros espirituais brilham. Uma passagem verdadeira aparece entre as raízes.","Ana: Agora consigo perceber o que a ilusão escondia."],"")
	elif fase == 1:
		progresso.dados.pistas = true
		_salvar()
		_dialogo(["Ana: O atalho parece limpo demais. As pegadas não afundam no chão.","Ana: Na outra trilha, a raiz continua viva e as folhas estão amassadas. Alguém passou por ali."],"")
	elif fase == 3:
		_dialogo(["As pegadas invertidas voltam a aparecer. Algumas se desfazem em sombra.","Ana: Ele ainda está por perto… Preciso prestar atenção."],"")
	else:
		revelando = 6.0
		_dialogo(["Ana: As marcas fundas são reais. As folhas quebradas mostram o movimento, mesmo quando os pés apontam ao contrário."],"")

func _livro() -> void:
	if falando or em_batalha or viajando: return
	var nota := "Prudência: observar, compreender, decidir e agir."
	if progresso.dados.pistas: nota += "\nO atalho não deixa marcas. A raiz viva indica uma trilha verdadeira."
	if progresso.tem_bencao("passos_curupira"): nota += "\nPassos do Curupira: Observar revela rastros e ilusões."
	_dialogo([nota],"")

func _escolher(raiz: bool) -> void:
	if falando or viajando: return
	if raiz:
		fase = 2
		jogador.position = Vector2(180,490)
		_aplicar_fase()
		_dialogo(["A raiz continua entre as árvores. Atrás de Ana, o atalho parece desaparecer."],"")
	else:
		jogador.position = Vector2(180,490)
		_dialogo(["Ana: Essa pedra… eu já passei aqui. O caminho deu uma volta!", "Ana: Vou olhar as pistas antes de tentar de novo."],"")

func _interagir() -> void:
	if falando or em_batalha or viajando or not botao.visible: return
	if fase == 0:
		fase = 1
		jogador.position = Vector2(180,490)
		_aplicar_fase()
		_dialogo(["Duas trilhas se abrem. Uma parece um atalho; a outra acompanha uma raiz."],"")
	elif fase == 2: _iniciar_encontro()
	elif fase == 3:
		if progresso.tem_bencao("passos_curupira") and not caminho_revelado:
			_dialogo(["Ana: Há uma passagem aqui, mas as folhas escondem o caminho. Vou usar a bênção para observar."],"")
		else:
			_salvar()
			_dialogo(["Ana segue pela trilha. O encontro com Curupira ficará marcado na jornada.", "Fim do protótipo do capítulo da Prudência. O resultado foi salvo; os próximos capítulos continuarão daqui."],"")

func _iniciar_encontro() -> void:
	vistos.encontro = true
	encontro_pendente = true
	curupira.show()
	curupira.position = Vector2(850,451)
	curupira.modulate = Color.WHITE
	_dialogo(["Curupira: MAIS UMA HUMANA?! Pare aí! Já não tiraram o bastante desta floresta?", "Ana: Sou Ana. O Espírito da Sumaúma pediu minha ajuda.", "Curupira: Ajuda? As árvores estão morrendo! Os animais perderam suas casas! É CULPA DE VOCÊS!", "Uma mancha escura pulsa no braço ferido. Curupira range os dentes; as raízes rompem a terra ao redor dele.", "Ana: Seu braço… Tem alguma coisa acontecendo com você.", "Curupira: NÃO SE APROXIME! Enquanto eu estiver de pé, nenhum humano vai destruir mais nada!"],"")

func _avancar() -> void:
	super._avancar()
	if not falando and encontro_pendente:
		encontro_pendente = false
		em_batalha = true
		curupira.position = Vector2(850,451)
		curupira.modulate = Color.WHITE
		curupira.show()
		var batalha := preload("res://batalhas/batalha.gd").new()
		add_child(batalha)
		batalha.concluida.connect(_fim_batalha)
		batalha.iniciar(jogador,curupira,preload("res://batalhas/curupira_dados.gd").criar(),int(progresso.dados.ervas))

func _fim_batalha(resultado: String, ervas: int) -> void:
	em_batalha = false
	progresso.dados.ervas = ervas
	jogador.movimento_lateral = true
	jogador.position = Vector2(180,490)
	jogador.set_physics_process(true)
	fase = 2 if resultado == "recuou" else 3
	_aplicar_fase()
	if resultado == "recuou": _dialogo(["Ana: Aqui consigo recuperar o fôlego. Quando estiver pronta, posso voltar."],"")

func _unhandled_input(event: InputEvent) -> void:
	if em_batalha: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_O:
			_observar()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_L:
			_livro()
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)

func _som() -> void:
	var onda := AudioStreamWAV.new()
	onda.format = AudioStreamWAV.FORMAT_16_BITS
	onda.mix_rate = 22050
	var bytes := PackedByteArray()
	bytes.resize(11025*2)
	for i in range(11025):
		var t := float(i)/22050.0
		var amostra := int(sin(TAU*(650*t+180*t*t))*sin(PI*t/0.5)*1800)
		bytes.encode_s16(i*2,amostra)
	onda.data = bytes
	var som := AudioStreamPlayer2D.new()
	som.stream = onda
	som.position = Vector2(180,450)
	som.volume_db = -12
	add_child(som)
	som.finished.connect(som.queue_free)
	som.play()

func _draw() -> void:
	if not is_instance_valid(curupira): return
	if not em_batalha:
		for i in range(8):
			var x := 350.0+i*30
			var cor := Color("645b3d") if i%3 != 0 else Color("838578")
			if revelando > 0: cor = Color("c4d67a")
			draw_rect(Rect2(x,526+(i%2)*5,11,5),cor)
			draw_rect(Rect2(x-2 if i%3 == 0 else x+9,524+(i%2)*5,4,4),cor)
		if fase == 1:
			draw_line(Vector2(550,530),Vector2(1110,535),Color("8a7240"),5)
			for i in range(8): draw_rect(Rect2(620+i*42,510,9,3),Color("85948b"))
		if caminho_revelado:
			for i in range(9): draw_rect(Rect2(810+i*30,530+sin(i)*5,12,4),Color("dae798"))
		if animal_tempo > 0:
			var x := 1100-animal_tempo*900
			draw_rect(Rect2(x,494,21,12),Color("71553b"))
			draw_rect(Rect2(x+18,489,8,9),Color("71553b"))
			for i in range(2): draw_line(Vector2(x+i*15,503),Vector2(x+i*15+sin(relogio*25)*4,512),Color("42392c"),3)
	for i in range(10):
		var y := fmod(relogio*15+i*51,450.0)
		draw_rect(Rect2(100+i*99+sin(relogio+i)*15,y,5,3),Color(0.39,0.48,0.20,0.45))
