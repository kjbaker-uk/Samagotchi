extends CharacterBody2D

# Constants
const SPEED = 50
const RIGHT = Vector2.RIGHT
const LEFT = Vector2.LEFT
const UP = Vector2.UP
const DOWN = Vector2.DOWN

# States
enum States {
	IDLE,
	NEW_DIR,
	MOVE,
	TALK,
	INTERACT,
	PICKEDUP
}

# Variables
var current_state = States.IDLE
var dir = RIGHT
var start_pos
var is_dragging = false
var drag_offset = Vector2()
var is_mouse_over = false
var prev_mouse_position = Vector2()

func _ready():
	randomize()
	start_pos = position
	# Make sure the Area2D's mouse_entered and mouse_exited signals are connected
	$Area2D.connect("mouse_entered", Callable(self, "_on_Area2D_mouse_entered"))
	$Area2D.connect("mouse_exited", Callable(self, "_on_Area2D_mouse_exited"))

func _on_Area2D_mouse_entered():
	is_mouse_over = true

func _on_Area2D_mouse_exited():
	is_mouse_over = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_mouse_over:
				is_dragging = true
				drag_offset = global_position - event.global_position
				prev_mouse_position = event.global_position
			elif not event.pressed:
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position + drag_offset
		update_drag_orientation(event.global_position)

func update_drag_orientation(current_mouse_position):
	if current_mouse_position.x != prev_mouse_position.x:
		$AnimatedSprite2D.flip_h = current_mouse_position.x < prev_mouse_position.x
		$Timer.wait_time = .5
		prev_mouse_position = current_mouse_position

func _process(delta):
	if not is_dragging:
		match current_state:
			States.IDLE:
				$AnimatedSprite2D.play("idle")
			States.MOVE:
				$AnimatedSprite2D.play("walk")
				move_character(delta)
			States.TALK:
				$AnimatedSprite2D.play("talk")
			States.INTERACT:
				# Add your interaction logic here
				pass
			States.PICKEDUP:
				# Add your logic for when the character is picked up
				pass
	else:
		$AnimatedSprite2D.play("dragging")

func move_character(delta):
	position += dir * SPEED * delta
	update_orientation()
	constrain_movement()

func update_orientation():
	$AnimatedSprite2D.flip_h = dir == LEFT

func constrain_movement():
	var viewport_rect = get_viewport_rect()
	var screen_bounds = Rect2(Vector2.ZERO, viewport_rect.size)
	position.x = clamp(position.x, screen_bounds.position.x, screen_bounds.end.x)
	position.y = clamp(position.y, screen_bounds.position.y, screen_bounds.end.y)

func choose_direction():
	dir = choose([RIGHT, UP, LEFT, DOWN])

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([States.IDLE, States.NEW_DIR, States.MOVE, States.TALK])
	if current_state == States.NEW_DIR:
		choose_direction()


