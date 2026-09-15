extends RefCounted
# Rules independent of scene, UI and enemy art; future encounters supply their own data.
var dados: Dictionary
var hp: int
var vida: int
var ervas: int
var turno := 0
var ataques := 0
var observacoes := 0
var confianca := 0
var ferida := false
var energia := false
var sumauma := false
var livro := false
var arma_guardada := true
var ajuda := false
var status := "pendente"
var creditos: Dictionary = {}

func _init(config: Dictionary, itens: int = 3) -> void:
	dados = config
	hp = int(config.hp)
	vida = int(config.vida_ana)
	ervas = itens

func acoes() -> Dictionary:
	var opcoes := {"observar":"Observar", "conversar":"Conversar"}
	if ferida: opcoes["ferida"] = "Perguntar sobre a ferida"
	if energia: opcoes["sumauma"] = "Perguntar sobre a Sumaúma"
	if sumauma: opcoes["livro"] = "Mostrar o Livro"
	if not arma_guardada: opcoes["guardar"] = "Guardar arma"
	if livro: opcoes["ajudar"] = "Oferecer ajuda"
	return opcoes

func _credito(chave: String, valor: int) -> void:
	if not creditos.has(chave):
		confianca += valor
		creditos[chave] = true

func agir(acao: String) -> Array:
	if status != "pendente": return []
	var falas: Array = []
	if acao not in ["lutar","cura_ana","cura_guardiao","recuar"] and not acoes().has(acao): return []
	if acao.begins_with("cura_") and ervas <= 0: return ["Ana: Não tenho mais ervas."]
	if acao == "recuar": return ["Ana: Preciso me afastar e pensar. Posso voltar quando estiver pronta."]
	turno += 1
	if acao == "lutar":
		ataques += 1
		arma_guardada = false
		ajuda = false
		confianca -= 2
		hp = maxi(0,hp-int(dados.ataque_ana))
		falas = ["Ana ataca. Curupira finca os pés, cobre a ferida e cerra os punhos.", "Curupira: Eu sabia! Vocês só sabem ferir! Não vão tomar esta floresta de mim!"]
		if ataques == 1: falas.append("Nox: Isso. Mais rápido.")
		elif ataques == 2: falas.append("Nox: Ele atacou primeiro.")
		elif ataques == 3: falas.append("Nox: Viu? Está funcionando.")
		else: falas.append("Nox: Você já chegou até aqui. Vai parar agora?")
		if hp > 0 and hp < 30: falas.append("Nox: Só falta terminar.")
		if hp == 0: status = "corrompido"
		return falas
	if ataques > 0 and acao in ["observar","conversar"] and not creditos.has("nox_agir"):
		falas.append("Nox: Agora?")
		creditos.nox_agir = true
	match acao:
		"observar":
			observacoes = mini(3,observacoes+1)
			_credito("olhar"+str(observacoes),1)
			if observacoes == 1: falas.append("Ana: Ele está furioso. Aperta os punhos e avança quando me vê… mas a perna falha e ele protege o braço.")
			elif observacoes == 2:
				ferida = true
				falas.append("Ana: A ferida pulsa antes de cada explosão de raiva. Ele está sofrendo, mas continua tentando me expulsar.")
			else:
				energia = true
				falas.append("Ana: Essa energia escura se espalha quando ele fala dos humanos. Algo está alimentando o ódio dele… e as raízes respondem.")
		"conversar": falas.append("Curupira: Olhe em volta! Árvores secando, bichos fugindo… Vocês humanos fizeram isso! E agora querem que eu escute desculpas?")
		"ferida":
			_credito("ferida",1)
			falas.append("Curupira: Uma raiz me atingiu quando tentei impedir que ela apodrecesse! Eu sinto a floresta morrendo… e cada humano que aparece me faz querer… Saia de perto!")
		"sumauma":
			sumauma = true
			_credito("sumauma",1)
			falas.append("Ana: O Espírito da Sumaúma também está enfraquecendo. Vim descobrir por quê.")
			falas.append("Curupira: Até a Sumaúma…? Não use o nome dela para me enganar! Prove o que está dizendo!")
		"livro":
			livro = true
			_credito("livro",5)
			falas.append("Curupira: Essa marca… é da Sumaúma. Por que ela chamaria uma humana? Eu… essa coisa no meu braço não para de queimar!")
		"guardar":
			arma_guardada = true
			_credito("guardar",2)
			falas.append("Ana abaixa as mãos e guarda a arma. Curupira percebe que ela recuou de propósito.")
			if ataques > 0: falas.append("Nox: Depois de tudo que você fez?")
		"ajudar":
			if not arma_guardada:
				falas.append("Curupira: Você fala em ajudar, mas continua pronta para me ferir.")
			else:
				ajuda = true
				if confianca >= int(dados.confianca_necessaria):
					status = "aliado"
					falas.append("Curupira: Espere… Você podia ter me ferido e escolheu ficar. Ainda estou com raiva… mas estou ouvindo você.")
				else:
					falas.append("Curupira: Ainda não consigo confiar. Não se aproxime… as raízes estão reagindo de novo!")
					falas.append("Ana: Vou respeitar seu espaço e esperar o ataque passar.")
				if ataques > 0: falas.append("Nox: Você acha mesmo que ele vai confiar em você?")
		"cura_ana":
			ervas -= 1
			vida = mini(int(dados.vida_ana),vida+25)
			falas.append("Ana usa uma erva e recupera o fôlego.")
		"cura_guardiao":
			ervas -= 1
			hp = mini(int(dados.hp),hp+18)
			_credito("cura",3)
			falas.append("Ana deixa a erva ao alcance dele. Curupira aceita com cautela.")
	return falas

func apos_defesa(dano: int) -> void:
	vida = maxi(0,vida-dano)
	if ajuda and arma_guardada:
		confianca += 2 if dano == 0 else 1
	# Even after several attacks, living guardians can regain trust through patient defense.
