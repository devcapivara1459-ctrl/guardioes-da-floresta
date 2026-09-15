extends CanvasLayer

var jogador: CharacterBody2D
var convite: Button
var painel: PanelContainer
var nome: Label
var texto: Label
var ativo: bool = false
var processava: bool = true
var indice: int = 0
var conversa_do_livro: bool = false
var falas: Array = []

const CONVERSA_LIVRO = [
	["ANA", "Seu Francisco, encontrei este livro nas estantes. Ele caiu sozinho… Eu nunca tinha visto ele por aqui."],
	["SEU FRANCISCO", "Esse livro… não costuma se mostrar para qualquer um."],
	["ANA", "O senhor conhece ele?"],
	["SEU FRANCISCO", "Conheço o que ele guarda."],
	["SEU FRANCISCO", "E acho que começo a entender por que ele chamou você."],
	["ANA", "Me chamou? Mas… é só um livro, não é?"],
	["SEU FRANCISCO", "A criação inteira chama, Ana. Mas só escuta quem aprende a silenciar o coração."],
	["ANA", "Silenciar o coração… É como ficar quietinha para ouvir melhor?"],
	["SEU FRANCISCO", "Também é deixar a pressa de lado. Observar com carinho o que, todos os dias, passa despercebido."],
	["ANA", "E o que esse livro guarda?"],
	["SEU FRANCISCO", "Virtudes."],
	["ANA", "Virtudes… são algum tipo de poder?"],
	["SEU FRANCISCO", "São forças, sim. Mas não para dominar os outros. Para aprender a governar a si mesma."],
	["SEU FRANCISCO", "Veja aquela árvore pela janela. Ela precisa de um chão firme para criar raízes e resistir ao vento."],
	["SEU FRANCISCO", "A prudência é assim: observar, pensar e escolher com cuidado antes de agir."],
	["ANA", "Então… antes de abrir o livro, eu fiz bem em vir conversar com o senhor?"],
	["SEU FRANCISCO", "Fez, sim. Às vezes, o primeiro passo de uma grande descoberta é saber pedir orientação."],
	["ANA", "Obrigada, seu Francisco! Vou voltar para a minha sala favorita e ler este livro com calma."]
]

func _ready() -> void:
	layer = 25
	jogador = get_parent().get_node("jogador")
	convite = Button.new()
	add_child(convite)
	convite.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	convite.offset_left = -300
	convite.offset_right = -24
	convite.offset_top = -106
	convite.offset_bottom = -28
	convite.text = "Conversar com Francisco" if DisplayServer.is_touchscreen_available() else "E — Conversar com Francisco"
	convite.add_theme_font_size_override("font_size", 20)
	convite.focus_mode = Control.FOCUS_NONE
	convite.pressed.connect(_iniciar)
	convite.hide()
	painel = PanelContainer.new()
	add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_left = 24
	painel.offset_right = -24
	painel.offset_top = -230
	painel.offset_bottom = -20
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("16121e")
	estilo.border_color = Color("f2e5c4")
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 24
	estilo.content_margin_right = 24
	estilo.content_margin_top = 16
	estilo.content_margin_bottom = 16
	painel.add_theme_stylebox_override("panel", estilo)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	painel.add_child(coluna)
	nome = Label.new()
	nome.add_theme_font_size_override("font_size", 22)
	coluna.add_child(nome)
	texto = Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("font_size", 23)
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(texto)
	var continuar := Button.new()
	continuar.text = "Continuar" if DisplayServer.is_touchscreen_available() else "Continuar  [E / Enter / Espaço]"
	continuar.custom_minimum_size.y = 56
	continuar.focus_mode = Control.FOCUS_NONE
	continuar.pressed.connect(_avancar)
	coluna.add_child(continuar)
	painel.hide()

func _pode_conversar() -> bool:
	var pes := jogador.global_position + Vector2(15, 33)
	return Rect2(195, 422, 305, 90).has_point(pes) and jogador.ultima_direcao == "cima"

func _process(_delta: float) -> void:
	convite.visible = not ativo and _pode_conversar()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if ativo and event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		_avancar()
	elif not ativo and event.keycode == KEY_E and _pode_conversar():
		get_viewport().set_input_as_handled()
		_iniciar()

func _iniciar() -> void:
	if ativo or not _pode_conversar():
		return
	conversa_do_livro = get_tree().has_meta("manuscrito_coletado")
	if conversa_do_livro:
		falas = CONVERSA_LIVRO
	else:
		falas = [["SEU FRANCISCO", "Boa tarde, Ana. Procurando uma nova história? Fique à vontade para olhar as estantes."], ["ANA", "Obrigada, seu Francisco! Vou dar uma olhada."]]
	indice = 0
	ativo = true
	processava = jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.sprite.stop()
	jogador.sprite.animation = "cima"
	jogador.sprite.frame = 1
	convite.hide()
	painel.show()
	_mostrar_fala()

func _mostrar_fala() -> void:
	nome.text = falas[indice][0]
	texto.text = falas[indice][1]
	nome.add_theme_color_override("font_color", Color("f6cc78") if nome.text == "SEU FRANCISCO" else Color("d8adf3"))

func _avancar() -> void:
	if not ativo:
		return
	indice += 1
	if indice < falas.size():
		_mostrar_fala()
	else:
		ativo = false
		painel.hide()
		jogador.set_physics_process(processava)
		if conversa_do_livro:
			get_tree().set_meta("francisco_explicou_virtudes", true)

func mostrar_recusa_saida() -> void:
	if ativo:
		return
	conversa_do_livro = false
	var mensagem := "Ainda não quero ir para casa. Vou ficar mais um pouco na biblioteca e escolher algo para ler."
	if get_tree().has_meta("francisco_explicou_virtudes"):
		mensagem = "Não quero ir embora agora… Vou voltar para a minha sala favorita e descobrir o que esse livro guarda."
	elif get_tree().has_meta("manuscrito_coletado"):
		mensagem = "Ainda não vou embora. Preciso mostrar este livro ao seu Francisco primeiro."
	falas = [["ANA", mensagem]]
	indice = 0
	ativo = true
	processava = jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.ultima_direcao = "cima"
	jogador.sprite.stop()
	jogador.sprite.animation = "cima"
	jogador.sprite.frame = 1
	convite.hide()
	painel.show()
	_mostrar_fala()
