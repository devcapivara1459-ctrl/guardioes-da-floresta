extends RefCounted

const FOLHA = preload("res://ana-godot/ana-adolescente.png")
const PASSOS = preload("res://ana-godot/ana-passos-laterais.png")

static func aplicar(sprite: AnimatedSprite2D) -> void:
	# Bounds use visible pixels, excluding near-transparent generation artifacts.
	var regioes: Array[Rect2] = [
		Rect2(123,38,138,290), Rect2(469,38,142,290), Rect2(825,38,140,290),
		Rect2(125,391,136,290), Rect2(473,391,135,290), Rect2(829,391,135,290),
		Rect2(116,738,160,290), Rect2(469,738,134,294), Rect2(824,738,159,291),
		Rect2(108,1093,165,295), Rect2(484,1093,133,295), Rect2(808,1093,164,292)
	]
	var tamanho := Vector2(165, 295)
	var quadros := SpriteFrames.new()
	quadros.remove_animation("default")
	var nomes := ["baixo", "cima", "direita", "esquerda"]
	for linha in range(4):
		var nome: String = nomes[linha]
		quadros.add_animation(nome)
		quadros.set_animation_speed(nome, 8.5)
		for coluna in [0, 1, 2, 1]:
			var regiao := regioes[linha * 3 + coluna]
			var textura := AtlasTexture.new()
			textura.atlas = FOLHA
			textura.region = regiao
			textura.filter_clip = true
			textura.margin = Rect2(Vector2((tamanho.x-regiao.size.x)/2.0, tamanho.y-regiao.size.y), tamanho-regiao.size)
			quadros.add_frame(nome, textura)
	var passos: Array[Rect2] = [
		Rect2(206,29,182,401), Rect2(572,29,227,401),
		Rect2(968,40,199,390), Rect2(1367,29,185,401),
		Rect2(191,461,232,401), Rect2(576,472,202,390),
		Rect2(982,458,197,404), Rect2(1367,462,185,400)
	]
	for nome in ["direita", "esquerda"]:
		quadros.remove_animation(nome)
		quadros.add_animation(nome)
		for i in range(2):
			quadros.add_frame(nome, _passo(passos[0]))
		var caminhada: String = nome + "_andando"
		quadros.add_animation(caminhada)
		quadros.set_animation_speed(caminhada, 10.0)
		# Contact, absorption and passing for each leg. No idle frames in the cycle.
		for indice in [1,2,3,4,5,6]:
			quadros.add_frame(caminhada, _passo(passos[indice]))
	sprite.sprite_frames = quadros
	sprite.animation_changed.connect(func():
		var lateral := sprite.animation.begins_with("direita") or sprite.animation.begins_with("esquerda")
		sprite.scale = Vector2.ONE * (104.0 / (404.0 if lateral else 295.0))
		sprite.flip_h = sprite.animation.begins_with("esquerda")
	)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var inicia_lateral := sprite.animation.begins_with("direita") or sprite.animation.begins_with("esquerda")
	sprite.scale = Vector2.ONE * (104.0 / (404.0 if inicia_lateral else tamanho.y))
	sprite.flip_h = sprite.animation.begins_with("esquerda")
	sprite.position = Vector2(15, 33.5 - 52.0)

static func _passo(regiao: Rect2) -> AtlasTexture:
	var textura := AtlasTexture.new()
	textura.atlas = PASSOS
	textura.region = regiao
	textura.filter_clip = true
	var tamanho := Vector2(236,404)
	textura.margin = Rect2(Vector2((tamanho.x-regiao.size.x)/2.0,tamanho.y-regiao.size.y),tamanho-regiao.size)
	return textura
