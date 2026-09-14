extends CanvasLayer

@export_multiline var fala: String = "Adoro sentar aqui depois da escola… É tão tranquilo que até esqueço da hora. E, quando o livro é bom, parece que faço parte da história."
var jogador: CharacterBody2D
var processava: bool = true

func _ready() -> void:
	if get_tree().has_meta("introducao_ana_vista"):
		queue_free()
		return
	layer = 10
	jogador = get_parent().get_node("sala_favorita/jogador")
	processava = jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	var painel := PanelContainer.new()
	add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_left = 28
	painel.offset_right = -28
	painel.offset_top = -210
	painel.offset_bottom = -24
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("16121e")
	estilo.border_color = Color("f2e5c4")
	estilo.set_border_width_all(3)
	estilo.content_margin_left = 22
	estilo.content_margin_right = 22
	estilo.content_margin_top = 16
	estilo.content_margin_bottom = 16
	painel.add_theme_stylebox_override("panel", estilo)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	painel.add_child(coluna)
	var nome := Label.new()
	nome.text = "ANA"
	nome.add_theme_color_override("font_color", Color("f6cc78"))
	nome.add_theme_font_size_override("font_size", 22)
	coluna.add_child(nome)
	var texto := Label.new()
	texto.text = fala
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.add_theme_font_size_override("font_size", 22)
	coluna.add_child(texto)
	var botao := Button.new()
	botao.text = "Continuar  [Enter / Espaço / E]"
	botao.focus_mode = Control.FOCUS_NONE
	botao.pressed.connect(_fechar)
	coluna.add_child(botao)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
			get_viewport().set_input_as_handled()
			_fechar()

func _fechar() -> void:
	get_tree().set_meta("introducao_ana_vista", true)
	if is_instance_valid(jogador):
		jogador.set_physics_process(processava)
	queue_free()
