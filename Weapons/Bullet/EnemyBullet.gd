extends Area2D

export (int) var speed
var velocity = Vector2()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func start(_pos, _dir):
	position = _pos
	velocity = Vector2(speed,0).rotated(_dir)
	rotation = _dir
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_EnemyBullet_body_entered(body):
	queue_free()
