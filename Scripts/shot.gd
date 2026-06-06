extends Area2D

@export var velocidade: float = 600.0
@export var Shot_damage: int = 10
var direcao: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		
		if body.has_method("tomar_dano"):
			body.tomar_dano(Shot_damage)
		
		# Destrói o projétil ao colidir
		queue_free()
