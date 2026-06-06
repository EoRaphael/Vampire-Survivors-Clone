extends CharacterBody2D

@export var speed: float = 400.0
@export var max_vida: int = 100
@export var tiro_cena: PackedScene = preload("res://Scenes/shot.tscn")
@export var dano_atual: int = 10

var vida_atual: int
var inimigos_colados: Array[Node2D] = []
var tempo_decorrido: float = 0.0
var nivel_atual: int = 1
var xp_atual: int = 0
var xp_necessario: int = 50 # Quanto de XP precisa para o Level 2

@onready var timer_dano: Timer = $TimerDano
@onready var attack_range: Area2D = $AttackRange
@onready var timer_shot: Timer = $TimerShot
@onready var vidabarra: ProgressBar = $vidabarra

var hud: CanvasLayer = null

func _ready() -> void:
	vida_atual = max_vida
	vidabarra.max_value = max_vida 
	
	hud = get_tree().current_scene.get_node_or_null("HUD")
	
	# Inicializa a HUD com os dados do Player
	if hud:
		hud.atualizar_vida(vida_atual)
		hud.configurar_barra_xp(xp_necessario)
		hud.atualizar_level(nivel_atual)
		
	if timer_dano:
		timer_dano.one_shot = false

func _physics_process(delta):
	get_input()
	move_and_slide()
	vidabarra.value = vida_atual
	tempo_sobrevivido(delta)
	
func get_input():
	var input_direction = Input.get_vector("left","right","up","down")
	velocity = input_direction * speed
	
func update_hud() -> void:
	if hud:
		hud.atualizar_vida(vida_atual)
		
func tempo_sobrevivido(delta: float) -> void:
	tempo_decorrido += delta
	
	var minutos: int = int(tempo_decorrido) / 60
	var segundos: int = int(tempo_decorrido) % 60
	var tempo_formatado = "%02d:%02d" % [minutos, segundos]
	
	if hud:
		hud.atualizar_tempo(tempo_formatado)

# Shot
func _on_timer_shot_timeout() -> void:
	var target = nearby_enemy()
	
	if target and tiro_cena:
		var new_shot = tiro_cena.instantiate()
		new_shot.global_position = global_position
		new_shot.dano_do_tiro = dano_atual
		
		var shot_direction = global_position.direction_to(target.global_position)
		new_shot.direcao = shot_direction
		get_parent().add_child(new_shot)

func nearby_enemy() -> Node2D:
	var bodys_no_alcance = attack_range.get_overlapping_bodies()
	var nearest_enemy: Node2D = null
	var shortet_distance: float = 99999.0
	
	for body in bodys_no_alcance:
		if body.is_in_group("enemy") and is_instance_valid(body):
			var distance = global_position.distance_to(body.global_position)
			
			if distance < shortet_distance:
				shortet_distance = distance
				nearest_enemy = body
	return nearest_enemy

# ENEMY DAMAGE
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if not inimigos_colados.has(body):
			inimigos_colados.append(body)
	
		is_damage()
		
		if timer_dano and timer_dano.is_inside_tree() and timer_dano.is_stopped():
			timer_dano.start()

func _on_timer_dano_timeout() -> void:
	is_damage()
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		inimigos_colados.erase(body)
		
		if inimigos_colados.is_empty() and timer_dano and not timer_dano.is_stopped():
			timer_dano.stop()

func is_damage() -> void:
	if inimigos_colados.is_empty():
		if timer_dano and not timer_dano.is_stopped():
			timer_dano.stop()
		return
		
	for inimigo in inimigos_colados:
		if is_instance_valid(inimigo):
			vida_atual -= inimigo.dano
			print("Dano recebido: ", inimigo.dano)
	
	vida_atual = max(vida_atual, 0)
	update_hud()
	
	if vida_atual <= 0:
		print("PLAYER MORREU!")
		if timer_dano and not timer_dano.is_stopped():
			timer_dano.stop()
			
		var minutos: int = int(tempo_decorrido) / 60
		var segundos: int = int(tempo_decorrido) % 60
		Global.tempo_final = "%02d:%02d" % [minutos, segundos]
		
		if tiro_cena:
			var tela_derrota = load("res://Scenes/defeatScreen.tscn").instantiate()
			get_tree().current_scene.add_child(tela_derrota)
		await get_tree().create_timer(0.1).timeout
		get_tree().paused = true
		
		
func ganhar_xp(quantidade: int) -> void:
	xp_atual += quantidade
	print("Ganhou ", quantidade, " de XP! Total: ", xp_atual, "/", xp_necessario)
	
	# Se bateu ou passou da meta de XP, sobe de nível
	while xp_atual >= xp_necessario:
		subir_de_nivel()
		
	if hud:
		hud.atualizar_xp(xp_atual, xp_necessario)

func subir_de_nivel() -> void:
	# Desconta o XP gasto para subir de nível (mantém o "resto" para o próximo nível)
	xp_atual -= xp_necessario
	nivel_atual += 1
	
	# Curva de Experiência: Aumenta a meta em 20% para o próximo nível
	xp_necessario = int(xp_necessario * 1.2)
	
	print("SUBIU DE NÍVEL! Agora você está no Nível: ", nivel_atual)
	
	if hud:
		hud.atualizar_level(nivel_atual)
		hud.configurar_barra_xp(xp_necessario)
		hud.abrir_menu_level_up()
		
	if hud:
		hud.atualizar_vida(vida_atual)
		

func aplicar_upgrade_dinamico(carta: UpgradeResource) -> void:
	print("Aplicando upgrade: ", carta.nome)
	
	if carta.tipo_atributo == "cura":
		vida_atual = min(vida_atual + int(carta.valor_alteracao), max_vida)
		
	else:
		var valor_atual = get(carta.tipo_atributo)
	
		set(carta.tipo_atributo, valor_atual + carta.valor_alteracao)
		
		if carta.tipo_atributo == "max_vida":
			vida_atual += int(carta.valor_alteracao)
			if hud: hud.configurar_barra_vida(max_vida)

	if hud:
		hud.atualizar_vida(vida_atual)
