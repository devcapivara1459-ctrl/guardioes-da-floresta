extends Area2D

@export_file("*.tscn") var cena_destino: String = "res://cenas/prologo/sala_estantes.tscn"
@export var definir_chegada: bool = false
@export var posicao_chegada: Vector2 = Vector2.ZERO
var trocando: bool = false

func _ready() -> void:
	body_entered.connect(_ao_entrar)

func _ao_entrar(corpo: Node2D) -> void:
	if trocando or not corpo is CharacterBody2D or not corpo.is_in_group("jogador"):
		return
	trocando = true
	call_deferred("_trocar_sala")

func _trocar_sala() -> void:
	if definir_chegada:
		get_tree().set_meta("chegada_porta", posicao_chegada)
	var erro := get_tree().change_scene_to_file(cena_destino)
	if erro != OK:
		if get_tree().has_meta("chegada_porta"):
			get_tree().remove_meta("chegada_porta")
		trocando = false
		push_error("Nao foi possivel abrir: " + cena_destino)
