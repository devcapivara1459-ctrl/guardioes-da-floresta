extends Node2D
signal terminou(dano: int)
signal investida
var jogador: CharacterBody2D
var padrao := "raizes"
var nivel := 0
var tempo := 0.0
var intervalo := 0.0
var invencivel := 0.0
var dano := 0
var ativo := false
var ataques: Array[Dictionary] = []
var revela := false
const ARENA := Rect2(80,440,900,90)
const RAIZES = preload("res://assets/personagens/curupira/curupira-raizes.png")
const RECORTE = preload("res://shaders/raizes.gdshader")
var textura_fogo: Texture2D
const CORTES_FOGO := [0,172,410,716,1060,1380,1690,1930,2172]

func _animar_fogo(ataque: Dictionary, t: float) -> void:
	if not ataque.has("sprite"):
		var sprite := Sprite2D.new()
		sprite.texture = textura_fogo
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.region_enabled = true
		sprite.flip_h = true
		add_child(sprite)
		ataque.sprite = sprite
	var sprite: Sprite2D = ataque.sprite
	var quadro := 0 if t < 0 else 2+int(t*10.0)%4
	var fator := textura_fogo.get_width()/2172.0
	var largura: float = (CORTES_FOGO[quadro+1]-CORTES_FOGO[quadro])*fator
	sprite.region_rect = Rect2(CORTES_FOGO[quadro]*fator,230*fator,largura,230*fator)
	sprite.scale = Vector2(90.0/largura,0.25/fator)
	sprite.position = Vector2(880.0-maxf(0,t)*480.0,float(ataque.y))
	sprite.visible = t < 1.75

func _animar_raiz(ataque: Dictionary, t: float) -> void:
	if not ataque.has("sprite"):
		var sprite := Sprite2D.new()
		sprite.texture = RAIZES
		sprite.hframes = 8
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.centered = false
		sprite.scale = Vector2.ONE * 0.20
		sprite.position = Vector2(float(ataque.x)-RAIZES.get_width()/8.0*0.10,522-RAIZES.get_height()*0.936*0.20)
		var recorte := ShaderMaterial.new()
		recorte.shader = RECORTE
		sprite.material = recorte
		add_child(sprite)
		ataque.sprite = sprite
	var raiz: Sprite2D = ataque.sprite
	raiz.visible = t < 0.73
	if t < 0:
		raiz.frame = 0 if t < -0.25 else 1
	elif t < 0.55:
		raiz.frame = mini(6, 2+int(t/0.11))
	else:
		raiz.frame = 7

func iniciar(pessoa: CharacterBody2D, tipo: String, dificuldade: int, bencao: bool = false) -> void:
	jogador = pessoa
	padrao = tipo
	if padrao == "fogo": textura_fogo = preload("res://scripts/batalhas/textura_recortada.gd").carregar("res://assets/personagens/curupira/curupira-cipo-fogo.png")
	nivel = dificuldade
	revela = bencao
	jogador.movimento_lateral = false
	jogador.position = Vector2(260,460)
	jogador.set_physics_process(true)
	ativo = true
	z_index = 5

func _process(delta: float) -> void:
	if not ativo: return
	tempo += delta
	intervalo -= delta
	invencivel = maxf(0,invencivel-delta)
	jogador.position.x = clampf(jogador.position.x,80,945)
	jogador.position.y = clampf(jogador.position.y,429,485)
	jogador.modulate.a = 0.55 if invencivel > 0 else 1.0
	if intervalo <= 0 and tempo < 4.0:
		investida.emit()
		intervalo = 1.8
		var ponto := jogador.position + Vector2(15,33.5)
		var aviso := 1.1 if nivel < 3 else 0.9
		if padrao == "fogo":
			ataques.append({"idade":0.0,"aviso":1.2,"x":880.0,"y":ponto.y,"tipo":"fogo","falso":false})
		elif padrao == "sementes":
			ataques.append({"idade":0.0,"aviso":aviso,"x":80.0,"y":ponto.y,"tipo":"semente","falso":false})
		else:
			ataques.append({"idade":0.0,"aviso":aviso,"x":ponto.x,"y":450.0,"tipo":"raiz","falso":false})
			if padrao == "ilusao":
				ataques.append({"idade":0.0,"aviso":aviso,"x":clampf(ponto.x+170,140,900),"y":450.0,"tipo":"raiz","falso":true})
	for ataque in ataques:
		ataque.idade += delta
		var t: float = ataque.idade-ataque.aviso
		if ataque.tipo == "raiz" and not ataque.falso: _animar_raiz(ataque,t)
		if ataque.tipo == "fogo": _animar_fogo(ataque,t)
		if t < 0 or ataque.falso: continue
		var pes := jogador.position + Vector2(15,33.5)
		var acertou := false
		if ataque.tipo == "fogo" and t < 1.75:
			acertou = absf(pes.x-(880.0-t*480.0)) < 40 and absf(pes.y-float(ataque.y)) < 16
		elif ataque.tipo == "raiz" and t < 0.55:
			acertou = absf(pes.x-float(ataque.x)) < 36
		elif ataque.tipo == "semente" and t < 1.7:
			acertou = pes.distance_to(Vector2(80+t*530,float(ataque.y))) < 20
		if acertou and invencivel <= 0:
			dano += 8
			invencivel = 0.85
	if tempo >= 6.5:
		ativo = false
		jogador.modulate = Color.WHITE
		jogador.movimento_lateral = true
		jogador.set_physics_process(false)
		jogador.velocity = Vector2.ZERO
		jogador.sprite.stop()
		terminou.emit(dano)
	queue_redraw()

func _draw() -> void:
	if not ativo: return
	draw_rect(ARENA,Color(0.5,0.75,0.5,0.08))
	draw_rect(ARENA,Color(0.65,0.8,0.5,0.45),false,2)
	for ataque in ataques:
		var t: float = ataque.idade-ataque.aviso
		if t > 1.7: continue
		var cor := Color("d6c978") if not ataque.falso else Color("86748a")
		if ataque.falso and revela: cor.a = 0.18
		if t < 0:
			if ataque.tipo == "fogo":
				draw_line(Vector2(90,ataque.y),Vector2(875,ataque.y),Color(1.0,0.45,0.15,0.4),2)
			elif ataque.tipo == "semente":
				for i in range(4): draw_rect(Rect2(85+i*8,ataque.y+sin(tempo*18+i)*5,5,3),cor)
			else:
				var x: float = ataque.x
				for i in range(4): draw_rect(Rect2(x-24+i*14,514+sin(tempo*20+i)*2,8,4),cor)
				if not ataque.falso: draw_line(Vector2(x-34,518),Vector2(x+34,518),cor,3)
		elif not ataque.falso:
			if ataque.tipo == "semente":
				draw_circle(Vector2(80+t*530,ataque.y),8,Color("baac69"))
