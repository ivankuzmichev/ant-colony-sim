extends Node2D

@export var soil_grid_path: NodePath  # Ссылка на SoilGrid
@onready var soil: SoilGrid = get_node(soil_grid_path)  # Получаем SoilGrid

func _ready() -> void:
	print("SoilGrid ready:", soil)  # Проверка, что SoilGrid инициализирован правильно

	# Пример работы с SoilGrid
	var cell: Vector2i = Vector2i(1, 1)
	if soil.is_cell_solid(cell):
		print("Клетка с почвой")
	else:
		print("Клетка пустая")
