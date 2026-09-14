extends Node2D
signal concluida(resultado: String, ervas: int)
const Modelo = preload("res://batalhas/encontro.gd")
var modelo
var jogador: CharacterBody2D
var guardiao: Sprite2D
var dialogo
var ui: CanvasLayer
var painel: PanelContainer
var grade: GridContainer
var titulo: Label
var instrucao: Label
var barra: ProgressBar
var bloqueado := false
var resolvendo := false
var tempo := 0.0
var nox := 0
var corrupcao := 0.0

func iniciar(pessoa: CharacterBody2D, inimigo: Sprite2D, config: Dictionary, ervas: int) -> void:
	jogador = pessoa
	guardiao = inimigo
	var regras = config.get("regras",Modelo)
	modelo = regras.new(config,ervas)
	jogador.set_physics_process(false)
	jogador.velocity = Vector2.ZERO
	jogador.sprite.stop()
	ui = CanvasLayer.new()
	ui.layer = 25
	add_child(ui)
	titulo = Label.new()
	titulo.position = Vector2(28,62)
	titulo.add_theme_font_size_override("font_size",26)
	ui.add_child(titulo)
	barra = ProgressBar.new()
	barra.position = Vector2(28,100)
	barra.size = Vector2(290,18)
	barra.max_value = modelo.dados.hp
	barra.show_percentage = false
	var fundo_barra := StyleBoxFlat.new()
	fundo_barra.bg_color = Color("27372f")
	barra.add_theme_stylebox_override("background",fundo_barra)
	var vida_barra := StyleBoxFlat.new()
	vida_barra.bg_color = Color("85ad64")
	barra.add_theme_stylebox_override("fill",vida_barra)
	ui.add_child(barra)
	instrucao = Label.new()
	instrucao.position = Vector2(28,135)
	instrucao.add_theme_font_size_override("font_size",20)
	ui.add_child(instrucao)
	painel = PanelContainer.new()
	ui.add_child(painel)
	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_left = 24
	painel.offset_right = -24
	painel.offset_top = -128
	painel.offset_bottom = -18
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("172b23")
	estilo.border_color = Color("c8b47b")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(10)
	painel.add_theme_stylebox_override("panel",estilo)
	grade = GridContainer.new()
	grade.columns = 4
	grade.add_theme_constant_override("h_separation",10)
	grade.add_theme_constant_override("v_separation",6)
	painel.add_child(grade)
	dialogo = preload("res://sistemas/dialogo.gd").new()
	add_child(dialogo)
	_menu()

func _limpar() -> void:
	for filho in grade.get_children():
		grade.remove_child(filho)
		filho.queue_free()

func _botao(texto: String, acao: Callable) -> void:
	var b := Button.new()
	b.text = texto
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size.y = 40
	b.add_theme_font_size_override("font_size",20)
	b.pressed.connect(acao)
	grade.add_child(b)

func _menu() -> void:
	bloqueado = false
	painel.show()
	grade.columns = 4
	_limpar()
	_botao("LUTAR",func(): _acao("lutar"))
	_botao("AGIR",_agir)
	_botao("ITEM",_itens)
	_botao("RECUAR",func(): _acao("recuar"))
	titulo.text = str(modelo.dados.nome) + "   •   Fôlego de Ana: " + str(modelo.vida)
	barra.value = modelo.hp
	instrucao.text = "Observe antes de decidir. A confiança se revela pelas atitudes."
	grade.get_child(0).grab_focus()
	_ajustar_painel()

func _agir() -> void:
	_limpar()
	grade.columns = 3
	for chave in modelo.acoes(): _botao(modelo.acoes()[chave],_acao.bind(chave))
	_botao("Voltar",_menu)
	grade.get_child(0).grab_focus()
	_ajustar_painel()

func _itens() -> void:
	_limpar()
	grade.columns = 3
	_botao("Erva para Ana ("+str(modelo.ervas)+")",func(): _acao("cura_ana"))
	_botao("Erva para Curupira",func(): _acao("cura_guardiao"))
	_botao("Voltar",_menu)
	grade.get_child(0).disabled = modelo.ervas <= 0
	grade.get_child(1).disabled = modelo.ervas <= 0
	grade.get_child(2).grab_focus()
	_ajustar_painel()

func _ajustar_painel() -> void:
	var linhas := ceili(float(grade.get_child_count())/grade.columns)
	painel.offset_top = -maxi(100,linhas*46+42)

func _acao(chave: String) -> void:
	if bloqueado or resolvendo: return
	bloqueado = true
	painel.hide()
	var falas: Array = modelo.agir(chave)
	if falas.is_empty():
		_menu()
		return
	nox = mini(3,modelo.ataques)
	barra.value = modelo.hp
	if chave == "lutar":
		if guardiao.has_method("animar"): guardiao.animar("dano")
		var origem: float = guardiao.position.x
		guardiao.modulate = Color("ed8b82")
		var golpe := create_tween()
		golpe.tween_property(guardiao,"position:x",origem+12,0.08)
		golpe.tween_property(guardiao,"position:x",origem,0.15)
		golpe.parallel().tween_property(guardiao,"modulate",Color.WHITE,0.15)
	dialogo.mostrar(falas,jogador)
	await dialogo.terminou
	if chave == "recuar":
		concluida.emit("recuou",modelo.ervas)
		queue_free()
	elif modelo.status != "pendente": _resolver()
	else: _defender()

func _defender() -> void:
	if guardiao.has_method("animar"): guardiao.animar("ataque")
	var tipos: Array = modelo.dados.padroes
	var tipo: String = tipos[mini(int(modelo.turno/3),tipos.size()-1)]
	instrucao.text = {"raizes":"ESQUIVE • O chão marcado treme antes das raízes. Setas ou WASD.","sementes":"ESQUIVE • Folhas à esquerda anunciam sementes. Mova-se para cima/baixo.","ilusao":"OBSERVE • A marca firme no chão é real; os rastros pálidos enganam."}[tipo]
	var defesa := preload("res://batalhas/defesa.gd").new()
	add_child(defesa)
	defesa.investida.connect(func():
		if guardiao.has_method("animar"): guardiao.animar("ataque")
	)
	defesa.iniciar(jogador,tipo,modelo.turno,get_node("/root/Progresso").tem_bencao("passos_curupira"))
	var dano: int = await defesa.terminou
	defesa.queue_free()
	modelo.apos_defesa(dano)
	jogador.position = Vector2(300,490)
	if modelo.vida <= 0:
		dialogo.mostrar(["Ana: Preciso respirar… Vou recuar para a trilha e tentar de novo."],jogador)
		await dialogo.terminou
		concluida.emit("recuou",modelo.ervas)
		queue_free()
	else: _menu()

func _resolver() -> void:
	resolvendo = true
	var progresso = get_node("/root/Progresso")
	progresso.dados.ervas = modelo.ervas
	progresso.resolver_guardiao(modelo.dados.id,modelo.status,modelo.dados.bencao)
	progresso.salvar()
	if modelo.status == "aliado":
		guardiao.modulate = Color("d1efd0")
		dialogo.mostrar(["Curupira: Eu tentava proteger a região. As trilhas mudavam, os animais se perdiam… e aquela raiz me atingiu.","Curupira: Eu culpei você por tudo que os humanos fizeram. Cada lembrança fazia essa sombra queimar… e eu só queria atacar. Você me fez parar e olhar.","Ana: Ainda podemos descobrir o que está acontecendo.","Curupira: Vou com você, mesmo quando não puder ser visto. Siga os rastros que deixam marcas de verdade.","BÊNÇÃO RECEBIDA — PASSOS DO CURUPIRA\nUse Observar para distinguir ilusões e revelar passagens."],jogador)
		await dialogo.terminou
	else:
		var musica = get_node("/root/Trilha")
		var ponto: float = musica.get_playback_position()
		musica.stop()
		guardiao.rotation = 0.0
		if guardiao.has_method("animar"): guardiao.animar("queda")
		await get_tree().create_timer(2.0).timeout
		nox = 4
		dialogo.mostrar(["O guardião cai, ainda respirando. A floresta fica em silêncio.","Nox: Você fez a parte difícil por mim.","Ana: Espere… O que você está fazendo?"],jogador)
		await dialogo.terminou
		var sombra := create_tween()
		sombra.tween_property(self,"corrupcao",1.0,2.0)
		sombra.parallel().tween_property(guardiao,"modulate",Color("705082"),2.0)
		await sombra.finished
		dialogo.mostrar(["A sombra envolve as feridas. Curupira abre os olhos: há outra presença olhando através deles.","Ana: Eu o deixei vulnerável…", "Curupira desaparece nas sombras. A raiz continua silenciosa."],jogador)
		await dialogo.terminou
		guardiao.hide()
		musica.play(ponto)
		musica.modo_ambiente()
	concluida.emit(modelo.status,modelo.ervas)
	queue_free()

func _process(delta: float) -> void:
	tempo += delta
	if is_instance_valid(guardiao) and not resolvendo:
		guardiao.rotation = 0.0
	queue_redraw()

func _draw() -> void:
	if nox <= 0: return
	var centro := Vector2(1000,435)
	if nox >= 2:
		draw_colored_polygon(PackedVector2Array([centro+Vector2(-36,82),centro+Vector2(-23,-30),centro+Vector2(0,-60),centro+Vector2(26,-24),centro+Vector2(48,82)]),Color(0.09,0.06,0.14,0.30 if nox == 2 else 0.88))
	draw_rect(Rect2(centro+Vector2(-12,-21),Vector2(6,3)),Color("c49bd0"))
	draw_rect(Rect2(centro+Vector2(7,-21),Vector2(6,3)),Color("c49bd0"))
	if corrupcao > 0:
		for i in range(18):
			var t := fmod(tempo*0.5+i/18.0,1.0)
			var pos := centro.lerp(guardiao.position,t)+Vector2(0,sin(t*TAU+i)*18)
			draw_circle(pos,3+i%3,Color(0.23,0.10,0.32,corrupcao))
