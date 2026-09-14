extends Node2D
signal terminou(dano: int)
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

func iniciar(pessoa: CharacterBody2D, tipo: String, dificuldade: int, bencao: bool = false) -> void:
	jogador = pessoa
	padrao = tipo
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
		intervalo = 1.8
		var ponto := jogador.position + Vector2(15,33.5)
		var aviso := 1.1 if nivel < 3 else 0.9
		if padrao == "sementes":
			ataques.append({"idade":0.0,"aviso":aviso,"x":80.0,"y":ponto.y,"tipo":"semente","falso":false})
		else:
			ataques.append({"idade":0.0,"aviso":aviso,"x":ponto.x,"y":450.0,"tipo":"raiz","falso":false})
			if padrao == "ilusao":
				ataques.append({"idade":0.0,"aviso":aviso,"x":clampf(ponto.x+170,140,900),"y":450.0,"tipo":"raiz","falso":true})
	for ataque in ataques:
		ataque.idade += delta
		var t: float = ataque.idade-ataque.aviso
		if t < 0 or ataque.falso: continue
		var pes := jogador.position + Vector2(15,33.5)
		var acertou := false
		if ataque.tipo == "raiz" and t < 0.55:
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
			if ataque.tipo == "semente":
				for i in range(4): draw_rect(Rect2(85+i*8,ataque.y+sin(tempo*18+i)*5,5,3),cor)
			else:
				var x: float = ataque.x
				for i in range(4): draw_rect(Rect2(x-24+i*14,514+sin(tempo*20+i)*2,8,4),cor)
				if not ataque.falso: draw_line(Vector2(x-34,518),Vector2(x+34,518),cor,3)
		elif not ataque.falso:
			if ataque.tipo == "raiz" and t < 0.55:
				for i in range(3):
					var x: float = ataque.x-24+i*24
					draw_colored_polygon(PackedVector2Array([Vector2(x-10,522),Vector2(x+8,522),Vector2(x+sin(i)*10,445)]),Color("766346"))
			elif ataque.tipo == "semente":
				draw_circle(Vector2(80+t*530,ataque.y),8,Color("baac69"))
