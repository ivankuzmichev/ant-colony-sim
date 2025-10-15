extends Camera2D

@export var pan_speed: float = 800.0
@export var zoom_step: float = 0.1
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)
@export var max_zoom: Vector2 = Vector2(2.5, 2.5)

func _unhandled_input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom = (zoom * (1.0 - zoom_step)).clamp(min_zoom, max_zoom)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom = (zoom * (1.0 + zoom_step)).clamp(min_zoom, max_zoom)

func _process(delta):
    var dir := Vector2.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        dir.y -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        dir.y += 1
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        dir.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        dir.x += 1
    if dir != Vector2.ZERO:
        position += dir.normalized() * pan_speed * delta
