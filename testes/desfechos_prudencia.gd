extends SceneTree
var falhas := 0
func _initialize() -> void: call_deferred("testar")
func verificar(ok: bool, mensagem: String) -> void:
	if not ok:
		falhas += 1
		push_error(mensagem)
func testar() -> void:
	Engine.time_scale = 8.0
	var progresso = root.get_node("Progresso")
	progresso.caminho = "user://teste-prudencia-desfechos.cfg"
	for rota in ["aliado","corrompido"]:
		progresso.nova()
		progresso.dados.etapa = 2
		change_scene_to_file("res://cenas/capitulos/prudencia/prudencia.tscn")
		await scene_changed
		var cena = current_scene
		cena._iniciar_encontro()
		while cena.falando: cena._avancar()
		var b = cena.get_children().filter(func(n): return n.get_script() == preload("res://scripts/batalhas/batalha.gd"))[0]
		if rota == "aliado":
			for acao in ["observar","observar","observar","ferida","sumauma","livro"]: b.modelo.agir(acao)
			b._acao("ajudar")
		else:
			for i in range(4): b.modelo.agir("lutar")
			b._acao("lutar")
		var inicio := Time.get_ticks_msec()
		while cena.em_batalha and Time.get_ticks_msec()-inicio < 15000:
			if is_instance_valid(b) and b.dialogo.painel.visible: b.dialogo.avancar()
			await process_frame
		verificar(not cena.em_batalha,"desfecho deve terminar")
		verificar(cena.fase == 3,"história continua após desfecho")
		verificar(progresso.dados.curupira_status == rota,"status correto")
		verificar(cena.jogador.is_physics_processing(),"devolver controle")
		verificar(cena.curupira.visible == (rota == "aliado"),"corrompido desaparece, aliado permanece")
		progresso.carregar()
		verificar(progresso.dados.curupira_status == rota,"save do desfecho")
		if rota == "aliado":
			cena._observar()
			verificar(cena.caminho_revelado,"bênção revela passagem no cenário")
		print("PASS: cena final ",rota)
	Engine.time_scale = 1.0
	print("FALHAS: ",falhas)
	quit(falhas)
