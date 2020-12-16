extends RigidBody2D
enum States {INIT,ALIVE,INVULNERABLE,DEAD}

class_name Player

export (int) var engine_power
export (int) var spin_power

var screensize = Vector2()
var ship_state = null
var thrust = Vector2()
var rotation_dir = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(States.ALIVE)
	screensize = get_viewport().get_visible_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	
func _integrate_forces(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	var  xform = state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x =screensize.x
		
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	state.set_transform(xform)

func change_state(new_state):
	match new_state:
		States.INIT:
			$CollisionShape2D.disabled = true
		States.ALIVE:
			$CollisionShape2D.disabled = false
		States.INVULNERABLE:
			$CollisionShape2D.disabled = true
		States.DEAD:
			$CollisionShape2D.disabled = true
		
	ship_state = new_state

func get_input():
	thrust = Vector2()
	if ship_state in [States.DEAD,States.INIT]:
		return
	
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power,0)
	
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir +=1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -=1

