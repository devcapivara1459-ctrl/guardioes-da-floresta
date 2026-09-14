extends Sprite2D

var estado := "idle"
var idade := 0.0
const LINHAS := [0,220,425,640,820,1024]
const BASES := [214,420,634,814,1018]

func _ready() -> void:
	texture = preload("res://batalhas/textura_recortada.gd").carregar("res://ana-godot/curupira-animado.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	region_enabled = true
	centered = false
	scale = Vector2.ONE * 0.7
	_quadro(0,0)

func animar(nome: String) -> void:
	estado = nome
	idade = 0.0
	_process(0.0)

func _process(delta: float) -> void:
	idade += delta
	var linha := 0
	var quadro := int(idade * 7.0) % 6
	match estado:
		"ataque":
			linha = 1
			quadro = mini(5,int(idade*8.0))
			if idade >= 0.95: animar("idle"); return
		"dano":
			linha = 2
			quadro = mini(5,int(idade*9.0))
			if idade >= 0.8: animar("idle"); return
		"queda":
			linha = 3
			quadro = mini(5,int(idade*5.0))
	_quadro(linha,quadro)

func _quadro(linha: int, quadro: int) -> void:
	region_rect = Rect2(quadro*256,LINHAS[linha],256,LINHAS[linha+1]-LINHAS[linha])
	# Align feet across differently sized rows, including the collapse sequence.
	offset = Vector2(-128,100-(BASES[linha]-LINHAS[linha]))
