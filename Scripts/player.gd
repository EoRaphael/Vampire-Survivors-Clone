extends CharacterBody2D

@export var speed = 400
@export var max_vida: int = 100
@export var tiro_cena: PackedScene = preload("res://Scenes/shot.tscn")

var vida_atual: int
var inimigos_colados: Array[Node2D] = []
var tempo_decorrido: float = 0.0

@onready var vida_texto: Label = $CanvasLayer/vida
@onready var vida_barra: ProgressBar = $CanvasLayer/vidabarra
@onready var timer_dano: Timer = $TimerDano

@onready var attack_range: Area2D = $AttackRange
@onready var timer_shot: Timer = $TimerShot

@onready var tempo_texto: Label = $CanvasLayer/TimerText

func _ready() -> void:
	vida_atual = max_vida
	if vida_barra:
		vida_barra.max_value = max_vida
	update_hud()
	if timer_dano:
		timer_dano.one_shot = false

func _physics_process(delta):
	get_input()
	move_and_slide()
	
	tempo_sobrevivido(delta)
	
func get_input():
	var input_direction = Input.get_vector("left","right","up","down")
	velocity = input_direction * speed
	
func update_hud() -> void:
	if vida_texto:
		vida_texto.text = "Vida: " + str(vida_atual)
		
	if vida_barra:
		vida_barra.value = vida_atual 
		
func tempo_sobrevivido(delta: float) -> void:
	tempo_decorrido += delta
	
	# Matemática simples para transformar segundos em minutos/segundos inteiros
	var minutos: int = int(tempo_decorrido) / 60
	var segundos: int = int(tempo_decorrido) % 60
	
	# Formata para ficar bonito com dois dígitos (ex: 02:05 em vez de 2:5)
	var tempo_formatado = "%02d:%02d" % [minutos, segundos]
	
	if tempo_texto:
		tempo_texto.text = tempo_formatado

# Shot
func _on_timer_shot_timeout() -> void:
	var target = nearby_enemy()
	
	if target and tiro_cena:
		var new_shot = tiro_cena.instantiate()

		new_shot.global_position = global_position
		
		var shot_direction = global_position.direction_to(target.global_position)
		new_shot.direcao = shot_direction
		get_parent().add_child(new_shot)

func nearby_enemy() -> Node2D:
	# Pega todos os bodys que estão dentro do círculo de alcance AGORA
	var bodys_no_alcance = attack_range.get_overlapping_bodies()
	var nearest_enemy: Node2D = null
	var shortet_distance: float = 99999.0 # Começa com um valor gigante para comparação
	
	for body in bodys_no_alcance:
		if body.is_in_group("enemy") and is_instance_valid(body):
			var distance = global_position.distance_to(body.global_position)
			
			# Se este inimigo estiver mais perto do que o anterior que checamos
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
		get_tree().paused = true
