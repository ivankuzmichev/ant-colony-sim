extends Node2D

@export var soil_grid_path: NodePath  # Ссылка на SoilGrid (где хранятся тайлы)
@export var length_in_tiles: float = 9.0  # Длина муравья в тайлах
@export var move_speed: float = 140.0
@export var dig_time: float = 1.2

@onready var soil: SoilGrid = get_node(soil_grid_path)
@onready var sprite: Sprite2D = $Sprite2D

var state := "idle"
var target_cell: Vector2i = Vector2i(-1, -1)
var target_pos: Vector2
var dig_timer := 0.0
var carrying_chunk := false
var carried_sid := 0
var carried_atlas := Vector2i(0, 0)

# Метод, который начинает выполнение работы
func _ready() -> void:
	_fit_scale_to_tiles()
	request_job()

# Устанавливаем масштаб муравья в зависимости от размера тайлов
func _fit_scale_to_tiles() -> void:
	if sprite.texture == null: return
	var tile_px := float(soil.soil.tile_set.tile_size.x)  # 16 для твоего TileSet
	var target_w := length_in_tiles * tile_px
	var s := target_w / float(sprite.texture.get_width())
	sprite.scale = Vector2(s, s)

# Метод для получения задания
func request_job() -> void:
	if carrying_chunk:
		state = "carry_to_cell"
		return
	target_cell = soil.take_next_dig_job()  # Берём следующий тайл для копки
	if target_cell.x != -1:
		target_pos = soil.world_pos(target_cell)
		state = "move"
	else:
		state = "idle"  # Если нет задач, остаёмся в idle

# Основной процесс
func _process(delta: float) -> void:
	match state:
		"move":
			var dir := target_pos - global_position
			if dir.length() > 2.0:
				global_position += dir.normalized() * move_speed * delta
			else:
				state = "dig"
				dig_timer = dig_time
		"dig":
			dig_timer -= delta
			if dig_timer <= 0.0:
				soil.excavate(target_cell)  # Копаем тайл
				carrying_chunk = true
				state = "find_empty_cell"  # Ищем пустую клетку для сброса
		"find_empty_cell":
			var empty_cell := find_nearest_empty_cell(target_cell, 5)
			if empty_cell != Vector2i(-1, -1):
				target_pos = soil.world_pos(empty_cell)
				state = "carry_to_cell"
		"carry_to_cell":
			var dir := target_pos - global_position
			if dir.length() > 2.0:
				global_position += dir.normalized() * move_speed * delta
			else:
				var drop_cell := target_cell  # Мы должны сбросить в найденную пустую клетку
				soil.place_soil(drop_cell, carried_sid, carried_atlas)  # Сбрасываем тайл
				carrying_chunk = false
				request_job()  # Берём следующее задание
		"idle":
			if Engine.get_process_frames() % 30 == 0:
				request_job()

# Метод поиска ближайшей пустой клетки, не ближе 5 клеток
func find_nearest_empty_cell(start_cell: Vector2i, min_distance: int = 5) -> Vector2i:
	for r in range(1, 10):  # Ищем в радиусе 10 клеток
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var cell := Vector2i(start_cell.x + dx, start_cell.y + dy)
				if not soil.is_solid(cell) and (start_cell.distance_to(cell) >= min_distance):
					return cell
	return Vector2i(-1, -1)  # Если нет пустых клеток, возвращаем -1
