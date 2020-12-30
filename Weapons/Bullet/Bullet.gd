extends Area2D
class_name Bullet

export (int) var speed

var velocity = Vector2()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func start(pos,dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed,0).rotated(dir)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
	queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage(1)
	queue_free()
