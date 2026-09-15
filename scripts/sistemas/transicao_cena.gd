extends CanvasLayer

var cortina: ColorRect
var ocupado := false

func viajar(destino: String, chegada: Vector2, jogador: CharacterBody2D) -> void:
	if ocupado:
		return
	ocupado = true
	layer = 100
	var processava := jogador.is_physics_processing()
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.get_node("AnimatedSprite2D").stop()
	cortina = ColorRect.new()
	cortina.color = Color(0.025,0.07,0.04,0)
	add_child(cortina)
	cortina.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fechar := create_tween()
	fechar.tween_property(cortina,"color:a",1.0,0.65)
	await fechar.finished
	get_tree().set_meta("chegada_porta",chegada)
	var erro := get_tree().change_scene_to_file(destino)
	if erro != OK:
		get_tree().remove_meta("chegada_porta")
		jogador.set_physics_process(processava)
		push_error("Não foi possível abrir " + destino)
		queue_free()
		return
	await get_tree().scene_changed
	var novo := get_tree().get_first_node_in_group("jogador") as CharacterBody2D
	var novo_processava := novo.is_physics_processing() if novo else false
	if novo:
		novo.set_physics_process(false)
	var abrir := create_tween()
	abrir.tween_interval(0.2)
	abrir.tween_property(cortina,"color:a",0.0,0.8)
	await abrir.finished
	if is_instance_valid(novo):
		novo.set_physics_process(novo_processava)
	queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		get_viewport().set_input_as_handled()
