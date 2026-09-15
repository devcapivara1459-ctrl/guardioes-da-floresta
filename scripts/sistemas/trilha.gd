extends AudioStreamPlayer

var ajuste: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var config := ConfigFile.new()
	config.load("user://opcoes.cfg")
	AudioServer.set_bus_volume_db(0, linear_to_db(float(config.get_value("audio", "volume", 80)) / 100.0))
	var musica := load("res://assets/audio/o-chamado-da-floresta.mp3") as AudioStreamMP3
	if musica == null:
		return
	musica.loop = true
	stream = musica
	volume_db = -40.0
	play()
	modo_ambiente()

func _ajustar(destino: float, duracao: float) -> void:
	if ajuste and ajuste.is_valid():
		ajuste.kill()
	ajuste = create_tween()
	ajuste.tween_property(self, "volume_db", destino, duracao)

func modo_menu() -> void:
	_ajustar(-8.0, 1.8)

func modo_ambiente() -> void:
	_ajustar(-24.0, 1.8)
