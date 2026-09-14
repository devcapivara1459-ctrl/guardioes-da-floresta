extends RefCounted

const FOLHA = preload("res://ana-godot/ana-adolescente.png")

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
	sprite.sprite_frames = quadros
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (104.0 / tamanho.y)
	sprite.position = Vector2(15, 33.5 - 52.0)
