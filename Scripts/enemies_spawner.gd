extends Node2D

@export var inimigo_cena: PackedScene = preload("res://Scenes/enemy.tscn")
@export var raio_minimo: float = 300.0
@export var raio_maximo: float = 700.0
@onready var timer_spawn: Timer = $TimerSpawn
var player: Node2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _on_timer_spawn_timeout() -> void:
	if inimigo_cena:
		var new_enemy = inimigo_cena.instantiate()

		var random_position = calcular_posicao_aleatoria()
		new_enemy.global_position = random_position

		get_parent().add_child(new_enemy)

func calcular_posicao_aleatoria() -> Vector2:
	var random_angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(random_angle), sin(random_angle))
	
	
	var random_distance = randf_range(raio_minimo, raio_maximo)
	var ponto_central = player.global_position if is_instance_valid(player) else global_position
	
	return ponto_central + (direction * random_distance)
