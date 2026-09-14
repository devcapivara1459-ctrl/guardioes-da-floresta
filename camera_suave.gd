extends Camera2D

@export var aproximacao: float = 1.18

func _ready() -> void:
	zoom = Vector2.ONE * aproximacao
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
	limit_left = 0
	limit_top = 0
	limit_right = 1152
	limit_bottom = 648
	position = Vector2.ZERO
	make_current()
	call_deferred("reset_smoothing")

func _process(delta: float) -> void:
	var corpo := get_parent() as CharacterBody2D
	var antecipacao := corpo.velocity * 0.10
	position = position.lerp(antecipacao, 1.0 - exp(-4.0 * delta))
