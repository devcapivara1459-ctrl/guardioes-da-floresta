extends Area2D

var reagindo: bool = false

func _ready() -> void:
	body_entered.connect(_ao_tentar_sair)

func _ao_tentar_sair(corpo: Node2D) -> void:
	if reagindo or not corpo is CharacterBody2D or not corpo.is_in_group("jogador"):
		return
	reagindo = true
	_recuar.call_deferred(corpo)

func _recuar(corpo: CharacterBody2D) -> void:
	corpo.global_position = Vector2(561, 480)
	corpo.velocity = Vector2.ZERO
	get_parent().get_node("ConversaFrancisco").mostrar_recusa_saida()
	reagindo = false
