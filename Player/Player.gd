extends RigidBody2D
enum States {INIT,ALIVE,INVULNERABLE,DEAD}

signal shoot
signal lives_changed
signal dead

class_name Player

export (PackedScene) var bullet
export (float) var fire_rate
export (int) var engine_power
export (int) var spin_power



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screensize = Vector2()
var ship_state = null
var thrust = Vector2()
var rotation_dir = 0
var can_shoot = true
var lives = 0 setget set_lives
var _start_position = Vector2()
var started = false

func set_lives(value):
	lives = value
	emit_signal("lives_changed", lives)

func start(start_position):
	_start_position = start_position
	$Sprite.show()
	self.lives = 3
	change_state(States.ALIVE)

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(States.INIT)
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate

func explode():
	$Explosion.show()
	$Explosion/AnimationPlayer.play("Explosion")
	self.lives -= 1
	if lives <= 0:
		change_state(States.DEAD)
	else:
		change_state(States.INVULNERABLE)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	
func _integrate_forces(state):
	var  xform = state.get_transform()
	if !started and ship_state == States.ALIVE:
		xform.origin.x = _start_position.x
		xform.origin.y = _start_position.y
		started = true
		
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	
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
			$Sprite.modulate.a = 0
		States.ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1.0
		States.INVULNERABLE:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = .5
			$InvTimer.start()
		States.DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
		
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
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if ship_state == States.INVULNERABLE:
		return
	emit_signal("shoot",bullet,$Muzzle.global_position,rotation)
	can_shoot = false
	$GunTimer.start()


func _on_GunTimer_timeout():
	can_shoot = true


func _on_InvTimer_timeout():
	change_state(States.ALIVE)


func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()


func _on_Player_body_entered(body):
	if body.is_in_group("rocks") and ship_state == States.ALIVE:
		body.explode()
		explode()
		

