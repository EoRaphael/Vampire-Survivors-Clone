extends CharacterBody2D

@export var max_hp: int = 50
@export var speed: float = 100
@export var dano: int = 15
@export var xp_orb_cena: PackedScene = preload("res://Scenes/xp_orb.tscn")

@onready var enemy_hp: ProgressBar = $enemy_life


var atual_hp: int
var player

func _ready() -> void:
	enemy_hp.max_value = max_hp
	atual_hp = max_hp
	update_hud()
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(_delta: float) -> void:
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance >  100.0:
			var direction := global_position.direction_to(player.global_position)
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
	else:
		player = get_tree().get_first_node_in_group("player")

func update_hud() -> void:
		
	if enemy_hp:
		enemy_hp.value = atual_hp 

func tomar_dano(quantidade: int) -> void:
	atual_hp -= quantidade
	update_hud()
	print("Inimigo tomou dano! Vida restante: ", atual_hp)
	
	if atual_hp <= 0:
		die()

func die() -> void:
	print("Inimigo derrotado!")
	if xp_orb_cena:
		var novo_orbe = xp_orb_cena.instantiate()
		novo_orbe.global_position = global_position 
		call_deferred("_criar_orbe_e_destruir")
		
func _criar_orbe_e_destruir() -> void:
	if xp_orb_cena:
		var novo_orbe = xp_orb_cena.instantiate()
		novo_orbe.global_position = global_position
		
		get_parent().add_child(novo_orbe)
		
	queue_free()

	
