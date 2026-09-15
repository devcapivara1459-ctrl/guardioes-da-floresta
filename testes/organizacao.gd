extends SceneTree
func _initialize() -> void:
	call_deferred("testar")
func testar() -> void:
	var progresso = root.get_node("Progresso")
	progresso.caminho = "user://teste-organizacao.cfg"
	for antiga in ["res://prudencia.tscn","res://floresta_sumauma.tscn"]:
		progresso.nova()
		progresso.resolver("aliado")
		assert(progresso.salvar(antiga))
		assert(progresso.carregar())
		assert(ResourceLoader.exists(progresso.dados.cena))
		assert(progresso.tem_bencao("passos_curupira"))
	verificar_cenas("res://cenas")
	print("PASS: cenas carregáveis e saves anteriores compatíveis")
	quit()
func verificar_cenas(pasta: String) -> void:
	for arquivo in DirAccess.get_files_at(pasta):
		if arquivo.ends_with(".tscn"):
			var cena = load(pasta+"/"+arquivo)
			assert(cena != null)
			var instancia = cena.instantiate()
			assert(instancia != null)
			instancia.free()
	for sub in DirAccess.get_directories_at(pasta): verificar_cenas(pasta+"/"+sub)
