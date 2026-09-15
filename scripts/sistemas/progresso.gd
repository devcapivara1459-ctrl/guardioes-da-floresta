extends Node

var caminho := "user://partida.cfg"
var dados: Dictionary = {}
var erro := ""
const FLAGS = ["introducao_ana_vista","manuscrito_caiu","manuscrito_coletado","francisco_explicou_virtudes","livro_na_mesa","portal_despertou","floresta_chegada_vista","floresta_bifurcacao","floresta_desvio","sumauma_encontro"]

func _ready() -> void:
	nova()

func nova() -> void:
	dados = {"versao":1,"cena":"res://cenas/capitulos/prudencia/prudencia.tscn","posicao":Vector2(180,490),"etapa":0,"pistas":false,"curupira_status":"pendente","guardioes":{},"bencaos":[],"ervas":3,"flags":{}}
	for flag in FLAGS:
		if get_tree().has_meta(flag): get_tree().remove_meta(flag)

func existe() -> bool:
	var cfg := ConfigFile.new()
	return cfg.load(caminho) == OK and cfg.get_value("partida","versao",0) == 1

func salvar(cena: String = "res://cenas/capitulos/prudencia/prudencia.tscn", posicao: Vector2 = Vector2(180,490)) -> bool:
	dados.cena = cena
	dados.posicao = posicao
	for flag in FLAGS:
		dados.flags[flag] = get_tree().has_meta(flag)
	var cfg := ConfigFile.new()
	for chave in dados: cfg.set_value("partida",chave,dados[chave])
	var resultado := cfg.save(caminho)
	erro = "" if resultado == OK else "Não foi possível salvar a partida."
	return resultado == OK

func carregar() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(caminho) != OK or cfg.get_value("partida","versao",0) != 1: return false
	var cena: String = cfg.get_value("partida","cena","")
	var antigas := {"res://prudencia.tscn":"res://cenas/capitulos/prudencia/prudencia.tscn", "res://floresta_sumauma.tscn":"res://cenas/floresta/floresta_sumauma.tscn"}
	cena = antigas.get(cena,cena)
	if cena not in ["res://cenas/capitulos/prudencia/prudencia.tscn","res://cenas/floresta/floresta_sumauma.tscn"]: return false
	nova()
	for chave in dados: dados[chave] = cfg.get_value("partida",chave,dados[chave])
	dados.cena = cena
	for flag in FLAGS:
		if dados.flags.get(flag,false): get_tree().set_meta(flag,true)
	get_tree().set_meta("chegada_porta",dados.posicao)
	return true

func tem_bencao(nome: String) -> bool:
	return nome in dados.bencaos

func resolver(status: String) -> void:
	resolver_guardiao("curupira",status,"passos_curupira")

func resolver_guardiao(id: String, status: String, bencao: String) -> void:
	if status not in ["aliado","corrompido"]: return
	dados.guardioes[id] = status
	if status == "aliado" and not tem_bencao(bencao): dados.bencaos.append(bencao)
	if status == "corrompido": dados.bencaos.erase(bencao)
	if id == "curupira":
		dados.curupira_status = status
		dados.etapa = 3

func consequencia_final() -> Dictionary:
	return {"aliados":["curupira"] if dados.curupira_status == "aliado" else [],"adversarios":["curupira"] if dados.curupira_status == "corrompido" else [],"revela_ilusoes":tem_bencao("passos_curupira")}
