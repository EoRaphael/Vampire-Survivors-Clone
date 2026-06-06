extends CanvasLayer

@onready var vida_texto: Label = $vida
@onready var tempo_texto: Label = $TimerText
@onready var xp_barra: ProgressBar = $xp_barra
@onready var level_texto: Label = $level

@onready var menu_level_up: Control = $MenuLevelUp
@onready var carta_1: Button = $MenuLevelUp/HBoxContainer/Carta1
@onready var carta_2: Button = $MenuLevelUp/HBoxContainer/Carta2
@onready var carta_3: Button = $MenuLevelUp/HBoxContainer/Carta3

@export var todas_as_cartas: Array[UpgradeResource] = [] 

var escolhas_atuais: Array = []
var player_ref: Node2D = null

func _ready() -> void:
	if menu_level_up: menu_level_up.visible = false
	carta_1.pressed.connect(_on_carta_escolhida.bind(0))
	carta_2.pressed.connect(_on_carta_escolhida.bind(1))
	carta_3.pressed.connect(_on_carta_escolhida.bind(2))
	player_ref = get_tree().get_first_node_in_group("player")

func configurar_barra_xp(max_xp: int) -> void:
	if xp_barra:
		xp_barra.max_value = max_xp
		xp_barra.value = 0

func atualizar_xp(xp_atual: int, max_xp: int) -> void:
	if xp_barra:
		xp_barra.max_value = max_xp
		xp_barra.value = xp_atual
		
func atualizar_level(level_atual: int) -> void:
	if level_texto:
		level_texto.text = "Nível: " + str(level_atual)

func atualizar_vida(vida_atual: int) -> void:
	if vida_texto:
		vida_texto.text = "Vida: " + str(vida_atual)
		

func atualizar_tempo(tempo_formatado: String) -> void:
	if tempo_texto:
		tempo_texto.text = tempo_formatado
		

func abrir_menu_level_up() -> void:
	if todas_as_cartas.is_empty():
		print("AVISO: Você esqueceu de colocar as cartas na lista da HUD no Inspector!")
		get_tree().paused = false
		return
		
	escolhas_atuais.clear()
	
	# Copia a lista para podermos embaralhar e pegar 3 cartas SEM REPETIÇÃO
	var pool_cartas = todas_as_cartas.duplicate()
	pool_cartas.shuffle() # Embaralha a lista
	
	# Pega as 3 primeiras cartas embaralhadas (ou o máximo disponível se tiver menos de 3)
	var quantidade_cartas = min(3, pool_cartas.size())
	for i in range(quantidade_cartas):
		escolhas_atuais.append(pool_cartas[i])
	
	# Atualiza o texto dos botões mostrando o Nome e a Descrição da carta
	carta_1.text = escolhas_atuais[0].nome + "\n" + escolhas_atuais[0].descricao
	carta_2.text = escolhas_atuais[1].nome + "\n" + escolhas_atuais[1].descricao
	carta_3.text = escolhas_atuais[2].nome + "\n" + escolhas_atuais[2].descricao
	
	carta_1.icon = escolhas_atuais[0].icone
	carta_2.icon = escolhas_atuais[1].icone
	carta_3.icon = escolhas_atuais[2].icone
	
	menu_level_up.visible = true
	get_tree().paused = true

func _on_carta_escolhida(indice: int) -> void:
	var recurso_escolhido = escolhas_atuais[indice]
	
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player")
		
	if player_ref and player_ref.has_method("aplicar_upgrade_dinamico"):
		# Passa o recurso INTEIRO para o player processar
		player_ref.aplicar_upgrade_dinamico(recurso_escolhido)
	
	menu_level_up.visible = false
	get_tree().paused = false
