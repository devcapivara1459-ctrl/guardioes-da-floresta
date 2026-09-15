extends SceneTree
const Modelo = preload("res://scripts/batalhas/encontro.gd")
const Dados = preload("res://scripts/batalhas/curupira_dados.gd")
var erros: Array[String] = []

func verificar(ok: bool, mensagem: String) -> void:
	if not ok:
		erros.append(mensagem)
		push_error(mensagem)

func _initialize() -> void:
	call_deferred("testar")

func caminho_pacifico(m) -> void:
	for acao in ["observar","observar","observar","ferida","sumauma","livro"]:
		m.agir(acao)
	if not m.arma_guardada: m.agir("guardar")
	m.agir("ajudar")
	for i in range(12):
		if m.status != "pendente": break
		m.apos_defesa(0)
		m.agir("ajudar")

func fechar_falas(cena) -> void:
	while cena.falando: cena._avancar()

func testar() -> void:
	var pacifico = Modelo.new(Dados.criar())
	caminho_pacifico(pacifico)
	verificar(pacifico.status == "aliado" and pacifico.hp == 100,"rota pacífica sem dano")
	var insistente = Modelo.new(Dados.criar())
	for i in range(20): insistente.agir("conversar")
	verificar(insistente.status == "pendente" and insistente.confianca == 0,"conversar repetidamente não resolve")
	verificar(not insistente.acoes().has("livro"),"ações dependem das descobertas")
	for golpes in range(1,5):
		var m = Modelo.new(Dados.criar())
		for i in range(golpes): m.agir("lutar")
		verificar(m.hp > 0 and m.status == "pendente","ataques não bloqueiam paz antes de HP zero")
		caminho_pacifico(m)
		verificar(m.status == "aliado","arrependimento após "+str(golpes)+" ataques")
	var morto = Modelo.new(Dados.criar())
	for i in range(5): morto.agir("lutar")
	verificar(morto.hp == 0 and morto.status == "corrompido","HP zero corrompe sem matar")
	morto.agir("observar")
	verificar(morto.status == "corrompido","rota encerrada após derrota")
	var itens = Modelo.new(Dados.criar(),1)
	itens.vida = 30
	itens.agir("cura_ana")
	verificar(itens.ervas == 0 and itens.vida == 55,"cura consome item")
	itens.agir("cura_ana")
	verificar(itens.ervas == 0 and itens.vida == 55,"item não pode ficar negativo")
	print("PASS: regras de confiança, violência, arrependimento e itens")
	var progresso = root.get_node("Progresso")
	progresso.caminho = "user://teste-prudencia-regras.cfg"
	for resultado in ["aliado","corrompido"]:
		progresso.nova()
		set_meta("sumauma_encontro",true)
		progresso.resolver(resultado)
		verificar(progresso.salvar(),"salvar resultado")
		progresso.nova()
		verificar(progresso.carregar(),"carregar resultado")
		verificar(progresso.dados.curupira_status == resultado,"resultado persiste")
		verificar(progresso.tem_bencao("passos_curupira") == (resultado == "aliado"),"bênção apenas da amizade")
		verificar(progresso.consequencia_final().revela_ilusoes == (resultado == "aliado"),"consequência futura exposta")
	print("PASS: save, bênção e consequências após carregar")
	progresso.nova()
	change_scene_to_file("res://cenas/capitulos/prudencia/prudencia.tscn")
	await scene_changed
	var cena = current_scene
	fechar_falas(cena)
	cena.jogador.position.x = 980
	cena._process(0.016)
	fechar_falas(cena)
	cena._process(0.016)
	cena._interagir()
	fechar_falas(cena)
	verificar(cena.fase == 1,"entrada na bifurcação")
	cena._escolher(false)
	fechar_falas(cena)
	verificar(cena.fase == 1 and cena.jogador.position.x == 180,"atalho errado retorna sem punição")
	cena._observar()
	fechar_falas(cena)
	verificar(progresso.dados.pistas,"observação registrada")
	cena._escolher(true)
	fechar_falas(cena)
	verificar(cena.fase == 2,"trilha correta avança")
	cena._iniciar_encontro()
	verificar(cena.curupira.visible,"guardião visível na conversa")
	fechar_falas(cena)
	verificar(cena.em_batalha,"diálogo inicia batalha")
	var batalha = cena.get_children().filter(func(n): return n.get_script() == preload("res://scripts/batalhas/batalha.gd"))[0]
	verificar(batalha.grade.get_child_count() == 4,"quatro escolhas iniciais")
	batalha._acao("observar")
	while batalha.dialogo.painel.visible: batalha.dialogo.avancar()
	await process_frame
	var defesa = batalha.get_children().filter(func(n): return n.get_script() == preload("res://scripts/batalhas/defesa.gd"))[0]
	defesa.set_process(false)
	defesa._process(0.01)
	verificar(defesa.ataques.size() > 0 and defesa.dano == 0,"telegráfico antes de dano")
	defesa._process(0.5)
	verificar(defesa.dano == 0,"aviso dá tempo para reagir")
	defesa.tempo = 6.4
	defesa._process(0.2)
	await process_frame
	verificar(not batalha.bloqueado,"menu volta após defesa")
	batalha._acao("recuar")
	while batalha.dialogo.painel.visible: batalha.dialogo.avancar()
	await process_frame
	verificar(not cena.em_batalha and cena.fase == 2,"recuar devolve exploração")
	print("PASS: fluxo exploração, bifurcação, encontro, turno, defesa e recuo")
	print("FALHAS: ",erros.size())
	quit(0 if erros.is_empty() else 1)
