extends Resource
class_name UpgradeResource

@export var nome: String = "Nome do Upgrade"
@export_multiline var descricao: String = "O que essa carta faz..."
@export var icone: Texture2D

# Define qual atributo do Player vai mudar e quanto vai mudar
@export_enum("speed", "dano_atual", "max_vida", "cura") var tipo_atributo: String = "speed"
@export var valor_alteracao: float = 0.0
