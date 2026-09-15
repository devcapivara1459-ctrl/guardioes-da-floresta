extends CanvasLayer

var cortina: ColorRect
var cartao: VBoxContainer

func _ready() -> void:
	layer = 100
	cortina = ColorRect.new()
	cortina.color = Color(0.015, 0.035, 0.025, 0)
	add_child(cortina)
	cortina.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	cortina.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cartao = VBoxContainer.new()
	cartao.add_theme_constant_override("separation", 22)
	centro.add_child(cartao)
	_linha("PRÓLOGO", 26, Color("d6b16b"))
	_linha("O Chamado da Floresta", 44, Color("f5e9cc"))
	_linha("Toda grande aventura começa com um chamado.", 22, Color("b4c6b5"))
	cartao.modulate.a = 0

func _linha(frase: String, tamanho: int, cor: Color) -> void:
	var label := Label.new()
	label.text = frase
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", tamanho)
	label.add_theme_color_override("font_color", cor)
	cartao.add_child(label)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()

func iniciar(musica: AudioStreamPlayer = null) -> void:
	var entrada := create_tween().set_parallel(true)
	entrada.tween_property(cortina, "color:a", 1.0, 0.7)
	if is_instance_valid(musica):
		musica.modo_ambiente()
	await entrada.finished
	var titulo := create_tween()
	titulo.tween_property(cartao, "modulate:a", 1.0, 0.65)
	titulo.tween_interval(2.0)
	titulo.tween_property(cartao, "modulate:a", 0.0, 0.5)
	await titulo.finished
	var erro := get_tree().change_scene_to_file("res://cenas/prologo/biblioteca.tscn")
	if erro != OK:
		push_error("Não foi possível abrir o capítulo 1.")
		queue_free()
		return
	await get_tree().scene_changed
	var dialogo := get_tree().current_scene.get_node_or_null("DialogoInicial") as CanvasLayer
	if is_instance_valid(dialogo):
		dialogo.hide()
	var revelar := create_tween()
	revelar.tween_property(cortina, "color:a", 0.0, 0.85)
	await revelar.finished
	if is_instance_valid(dialogo):
		dialogo.show()
	queue_free()

