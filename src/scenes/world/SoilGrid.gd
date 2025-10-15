extends Node2D

class_name SoilGrid  # Это позволяет использовать SoilGrid как тип в других скриптах

@export var tile_map: TileMap  # Ссылка на TileMap с почвой
var cell_state: Array = []     # Массив для хранения состояния клеток

# Инициализация состояния клеток (все клетки с почвой)
func _ready() -> void:
	var width: int = tile_map.get_size().x  # Получаем размер карты
	var height: int = tile_map.get_size().y
	for x in range(width):
		cell_state.append([])
		for y in range(height):
			cell_state[x].append(1)  # Все клетки с почвой (1 = почва)

# Проверка, есть ли почва в клетке
func is_cell_solid(cell: Vector2i) -> bool:
	if cell.x >= 0 and cell.y >= 0 and cell.x < cell_state.size() and cell.y < cell_state[cell.x].size():
		return cell_state[cell.x][cell.y] == 1  # Клетка с почвой
	return false

# Метод для выкапывания клетки (клетка становится пустой)
func dig_cell(cell: Vector2i) -> void:
	if is_cell_solid(cell):
		cell_state[cell.x][cell.y] = 0  # Клетка теперь пустая (0)

# Метод для получения мировых координат из координат клетки
func get_world_position(cell: Vector2i) -> Vector2:
	return tile_map.map_to_world(cell)

# Метод для получения координат клетки из мировых координат
func get_cell_from_world_position(world_pos: Vector2) -> Vector2i:
	return tile_map.world_to_map(world_pos)

# Метод для размещения почвы (новый тайл в клетке)
func place_soil_in_cell(cell: Vector2i, source_id: int) -> void:
	if cell.x >= 0 and cell.y >= 0 and cell.x < cell_state.size() and cell.y < cell_state[cell.x].size():
		tile_map.set_cell_item(cell.x, cell.y, source_id)  # Размещаем тайл
		cell_state[cell.x][cell.y] = 1  # Клетка снова с почвой (1)

# Метод для применения гравитации и падения тайла (поиск пустой клетки для падения)
func apply_gravity_and_fall(cell: Vector2i, source_id: int) -> void:
	var current_cell: Vector2i = cell  # Явно указываем тип для переменной current_cell
	while is_cell_solid(current_cell + Vector2i(0, 1)):  # Пока есть почва под текущей клеткой
		current_cell += Vector2i(0, 1)  # Падение вниз
	# Когда находим пустую клетку, устанавливаем новый тайл
	place_soil_in_cell(current_cell, source_id)
