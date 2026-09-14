extends Control

var painel: PanelContainer
var botoes: VBoxContainer
var ajuda: PanelContainer
var jogar: BaseButton
var opcoes: PanelContainer
var iniciando: bool = false

func _ready() -> void:
	var fundo := TextureRect.new()
	fundo.texture = preload("res://interface/menu-floresta.png")
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	painel = PanelContainer.new()
	painel.name = "PainelMenu"
	add_child(painel)
	painel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	botoes = VBoxContainer.new()
	botoes.add_theme_constant_override("separation", 0)
	painel.add_child(botoes)
	jogar = _botao_arte("jogar", "Jogar", _jogar)
	botoes.add_child(jogar)
	var continuar := _botao_arte("continuar", "Continuar", _continuar)
	continuar.disabled = not get_node("/root/Progresso").existe()
	continuar.modulate.a = 0.55 if continuar.disabled else 1.0
	continuar.tooltip_text = "Retomar último checkpoint" if not continuar.disabled else "Nenhuma partida salva disponível."
	botoes.add_child(continuar)
	botoes.add_child(_botao_arte("opcoes", "Opções", _mostrar_opcoes))
	botoes.add_child(_botao_arte("extras", "Extras", _mostrar_ajuda))
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		botoes.add_child(_botao_arte("sair", "Sair", func(): get_tree().quit()))
	_criar_ajuda()
	_criar_opcoes()
	_iniciar_musica()
	resized.connect(_organizar)
	_organizar()
	jogar.grab_focus()
	painel.modulate.a = 0
	create_tween().tween_property(painel,"modulate:a",1.0,0.45)

func _estilo(cor: Color, borda: Color, margem: int) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor
	estilo.border_color = borda
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(margem)
	return estilo

func _botao(titulo: String, acao: Callable) -> Button:
	var b := Button.new()
	b.text = titulo
	b.custom_minimum_size.y = 58
	b.add_theme_font_size_override("font_size",24)
	b.add_theme_color_override("font_color",Color("f9eac5"))
	b.add_theme_stylebox_override("normal",_estilo(Color("20362c"),Color("6e6948"),10))
	b.add_theme_stylebox_override("hover",_estilo(Color("385440"),Color("ecc77e"),10))
	b.add_theme_stylebox_override("pressed",_estilo(Color("14251d"),Color("ecc77e"),10))
	var foco := StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = Color("ffe1a0")
	foco.set_border_width_all(3)
	b.add_theme_stylebox_override("focus",foco)
	b.pressed.connect(acao)
	return b

func _criar_ajuda() -> void:
	ajuda = PanelContainer.new()
	ajuda.name = "Ajuda"
	add_child(ajuda)
	ajuda.add_theme_stylebox_override("panel",_estilo(Color("101e18"),Color("d8b774"),28))
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation",18)
	ajuda.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "Extras"
	titulo.add_theme_font_size_override("font_size",30)
	coluna.add_child(titulo)
	var t := Label.new()
	t.text = "Prólogo — O Chamado da Floresta\nExplore a biblioteca e siga o chamado até a Sumaúma. Sete regiões, sete virtudes e sete capítulos aguardam Ana.\n\nNovos capítulos chegarão conforme a aventura ganhar forma.\n\nMover: setas do teclado ou WASD.\nInteragir: E ou o botão que aparece na tela.\nAvançar falas: Enter, Espaço, E ou Continuar.\n\nAproxime-se dos objetos e olhe para seu Francisco para conversar."
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.add_theme_font_size_override("font_size",21)
	coluna.add_child(t)
	coluna.add_child(_botao("Voltar",_fechar_ajuda))
	ajuda.hide()

func _organizar() -> void:
	var largura := clampf(size.x * 0.275,260,335)
	painel.size = Vector2(largura, painel.get_combined_minimum_size().y)
	painel.position = Vector2(size.x * 0.035, size.y * 0.245)
	if is_instance_valid(opcoes):
		opcoes.size.x = minf(560, size.x-40)
		opcoes.position = Vector2((size.x-opcoes.size.x)/2, 100)
	ajuda.size.x = minf(640,size.x-40)
	ajuda.position = Vector2((size.x-ajuda.size.x)*0.5, maxf(20,(size.y-ajuda.get_combined_minimum_size().y)*0.5))

func _mostrar_ajuda() -> void:
	painel.hide()
	ajuda.show()
	_organizar()
	ajuda.get_child(0).get_child(2).grab_focus()

func _fechar_ajuda() -> void:
	ajuda.hide()
	painel.show()
	jogar.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (ajuda.visible or opcoes.visible):
		opcoes.hide()
		_fechar_ajuda()
		get_viewport().set_input_as_handled()

func _jogar() -> void:
	if iniciando:
		return
	iniciando = true
	get_node("/root/Progresso").nova()
	for chave in ["introducao_ana_vista","manuscrito_caiu","manuscrito_coletado","francisco_explicou_virtudes","chegada_porta","livro_na_mesa","portal_despertou","floresta_chegada_vista","floresta_chamado_encontrado","floresta_bifurcacao","floresta_desvio","floresta_ponte","sumauma_encontro"]:
		if get_tree().has_meta(chave):
			get_tree().remove_meta(chave)
	for botao in botoes.get_children():
		if botao is BaseButton:
			botao.disabled = true
	var transicao := CanvasLayer.new()
	transicao.name = "TransicaoCapitulo"
	transicao.set_script(preload("res://transicao_capitulo.gd"))
	get_tree().root.add_child(transicao)
	transicao.iniciar(get_node("/root/Trilha"))



func _botao_arte(arquivo: String, titulo: String, acao: Callable) -> TextureButton:
	var b := TextureButton.new()
	b.name = titulo
	b.texture_normal = load("res://interface/botao-" + arquivo + ".png")
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	b.custom_minimum_size = Vector2(300, 72)
	b.focus_mode = Control.FOCUS_ALL
	b.tooltip_text = titulo
	b.pressed.connect(acao)
	b.mouse_entered.connect(func():
		if not b.disabled: b.modulate = Color(1.18,1.18,1.08))
	b.mouse_exited.connect(func():
		if not b.disabled: b.modulate = Color.WHITE)
	b.focus_entered.connect(func(): b.modulate = Color(1.22,1.22,1.08))
	b.focus_exited.connect(func(): b.modulate = Color.WHITE)
	return b

func _criar_opcoes() -> void:
	opcoes = PanelContainer.new()
	opcoes.name = "Opcoes"
	add_child(opcoes)
	opcoes.add_theme_stylebox_override("panel",_estilo(Color("101e18"),Color("d8b774"),28))
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation",18)
	opcoes.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "Opções"
	titulo.add_theme_font_size_override("font_size",30)
	coluna.add_child(titulo)
	var legenda := Label.new()
	legenda.text = "Volume geral"
	coluna.add_child(legenda)
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 100
	volume.step = 1
	volume.custom_minimum_size = Vector2(420,48)
	var config := ConfigFile.new()
	config.load("user://opcoes.cfg")
	volume.value = float(config.get_value("audio","volume",80))
	AudioServer.set_bus_volume_db(0,linear_to_db(volume.value/100.0))
	volume.value_changed.connect(func(valor: float):
		AudioServer.set_bus_volume_db(0,linear_to_db(valor/100.0))
		config.set_value("audio","volume",valor)
		config.save("user://opcoes.cfg"))
	coluna.add_child(volume)
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		var tela := CheckButton.new()
		tela.text = "Tela cheia"
		tela.custom_minimum_size.y = 56
		tela.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		tela.toggled.connect(func(valor: bool):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if valor else DisplayServer.WINDOW_MODE_WINDOWED))
		coluna.add_child(tela)
	coluna.add_child(_botao("Voltar",func():
		opcoes.hide()
		painel.show()
		jogar.grab_focus()))
	opcoes.hide()

func _mostrar_opcoes() -> void:
	painel.hide()
	opcoes.show()
	_organizar()
	opcoes.get_child(0).get_child(2).grab_focus()

func _iniciar_musica() -> void:
	get_node("/root/Trilha").modo_menu()

func _continuar() -> void:
	var progresso = get_node("/root/Progresso")
	if iniciando or not progresso.carregar(): return
	iniciando = true
	get_node("/root/Trilha").modo_ambiente()
	get_tree().change_scene_to_file(progresso.dados.cena)
