extends RefCounted
# Remove only neutral background connected to the sheet edges. Whites enclosed
# by the character outline (eyes and teeth) are preserved.
static var cache: Dictionary = {}
static func carregar(caminho: String) -> Texture2D:
	if cache.has(caminho): return cache[caminho]
	var original: Texture2D = load(caminho)
	var img := original.get_image()
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var dados := img.get_data()
	var candidatos := PackedByteArray()
	candidatos.resize(w*h)
	for p in range(w*h):
		var i := p*4
		var menor := mini(dados[i],mini(dados[i+1],dados[i+2]))
		var maior := maxi(dados[i],maxi(dados[i+1],dados[i+2]))
		candidatos[p] = 1 if menor > 122 and maior-menor < 34 else 0
	var fila := PackedInt32Array()
	for x in range(w):
		for p in [x,(h-1)*w+x]:
			if candidatos[p] == 1: candidatos[p] = 2; fila.append(p)
	for y in range(h):
		for p in [y*w,y*w+w-1]:
			if candidatos[p] == 1: candidatos[p] = 2; fila.append(p)
	var cursor := 0
	while cursor < fila.size():
		var p := fila[cursor]
		cursor += 1
		dados[p*4+3] = 0
		for vizinho in [p-w,p+w,p-1 if p%w > 0 else -1,p+1 if p%w < w-1 else -1]:
			if vizinho >= 0 and vizinho < w*h and candidatos[vizinho] == 1:
				candidatos[vizinho] = 2
				fila.append(vizinho)
	cache[caminho] = ImageTexture.create_from_image(Image.create_from_data(w,h,false,Image.FORMAT_RGBA8,dados))
	return cache[caminho]
