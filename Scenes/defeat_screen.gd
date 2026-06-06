extends CanvasLayer

@onready var tempo_final_texto: Label = $FinalTime
@onready var botao_reiniciar: Button = $RestartButton

func _ready() -> void:
	
	# Recupera o tempo que salvamos no "Global" antes de morrer
	var tempo_salvo = Global.tempo_final
	tempo_final_texto.text = "Você sobreviveu por: " + tempo_salvo
	

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
