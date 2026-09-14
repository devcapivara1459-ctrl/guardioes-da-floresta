extends SceneTree
func _initialize() -> void:
	call_deferred("testar")
func testar() -> void:
	var progresso = root.get_node("Progresso")
	progresso.caminho = "user://teste-cipo-fogo.cfg"
	progresso.nova()
	progresso.dados.etapa = 2
	change_scene_to_file("res://prudencia.tscn")
	await scene_changed
	var pessoa = current_scene.jogador
	var defesa = preload("res://batalhas/defesa.gd").new()
	current_scene.add_child(defesa)
	defesa.iniciar(pessoa,"fogo",3)
	defesa.set_process(false)
	pessoa.set_physics_process(false)
	defesa._process(0.01)
	assert(defesa.dano == 0)
	assert(defesa.ataques[0].tipo == "fogo")
	defesa.intervalo = 99
	defesa._process(0.5)
	assert(defesa.dano == 0, "Aviso não pode causar dano")
	var t := 0.5
	pessoa.position = Vector2(880-t*480-15,460)
	defesa._process(1.19)
	assert(defesa.dano == 8, "Projétil precisa atingir a trajetória anunciada")
	defesa.invencivel = 0
	pessoa.position.y = 429
	defesa._process(0.01)
	assert(defesa.dano == 8, "Esquiva vertical deve evitar o dano")
	defesa._process(5)
	assert(not defesa.ativo)
	assert(pessoa.movimento_lateral)
	print("PASS: cipó de fogo, aviso sem dano, colisão, esquiva e fim do turno")
	quit()
