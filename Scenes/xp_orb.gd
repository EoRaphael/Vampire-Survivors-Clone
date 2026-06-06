extends Area2D

@export var valor_xp: int = 15

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("ganhar_xp"):
			body.ganhar_xp(valor_xp)
		
		queue_free()
		
		
		
