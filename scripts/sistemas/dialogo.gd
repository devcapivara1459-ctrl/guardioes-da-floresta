extends CanvasLayer
signal terminou
var painel: PanelContainer
var legenda: Label
var botao: Button
var falas: Array = []
var indice := 0
var jogador: CharacterBody2D
var retomar := false

func _ready() -> void:
	layer = 40
	painel = PanelContainer.new()
	add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_left = 24
	painel.offset_right = -24
	painel.offset_top = -208
	painel.offset_bottom = -20
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("14271f")
	estilo.border_color = Color("c5a76b")
	estilo.set_border_width_all(3)
	estilo.set_content_margin_all(18)
	painel.add_theme_stylebox_override("panel",estilo)
	var coluna := VBoxContainer.new()
	painel.add_child(coluna)
	legenda = Label.new()
	legenda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legenda.size_flags_vertical = Control.SIZE_EXPAND_FILL
	legenda.add_theme_font_size_override("font_size",23)
	coluna.add_child(legenda)
	botao = Button.new()
	botao.text = "Continuar [E]"
	botao.custom_minimum_size.y = 48
	botao.pressed.connect(avancar)
	coluna.add_child(botao)
	painel.hide()

func mostrar(textos: Array, pessoa: CharacterBody2D = null) -> void:
	falas = textos
	indice = 0
	jogador = pessoa
	retomar = jogador != null and jogador.is_physics_processing()
	if jogador:
		jogador.set_physics_process(false)
		jogador.velocity = Vector2.ZERO
		jogador.sprite.stop()
	legenda.text = str(falas[0])
	painel.show()
	botao.grab_focus()

func avancar() -> void:
	if not painel.visible: return
	indice += 1
	if indice < falas.size():
		legenda.text = str(falas[indice])
		return
	painel.hide()
	if is_instance_valid(jogador): jogador.set_physics_process(retomar)
	terminou.emit()

func _unhandled_input(event: InputEvent) -> void:
	if painel.visible and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_E,KEY_ENTER,KEY_SPACE]:
		avancar()
		get_viewport().set_input_as_handled()
