extends Area2D
signal shoot
signal ecploded

class_name Enemy

export (PackedScene) var bullet
export (int) var speed= 150
export (int) var health = 3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var follow
var target = null

func shoot():
	var dir = target.global_position  - global_position
	dir = dir.rotated(rand_range(-.1,.1)).angle()
	#emit_signal("shoot",bullet,global_position,dir)
	emit_signal("shoot",bullet,$Muzzle.global_position,dir)
	
func shoot_pulse(n,delay):
		for i in range(n):
			shoot()
			yield(get_tree().create_timer(delay),"timeout")

func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
	yield($AnimationPlayer,"animation_finished")
	$AnimationPlayer.play("rotate")
	
func explode():
	speed = 0
	$GunTimer.stop()
	$CollisionShape2D.disabled = true
	$Sprite.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("Explosion")
	$ExplosionSound.play()
	emit_signal("ecploded")

func spawn(path,trgt):
	$Explosion.hide()
	$Sprite.frame = randi() % 3
	follow = PathFollow2D.new()
	path.add_child(follow)
	follow.loop = false
	target = trgt
	
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
#	$Sprite.frame = randi() % 3
#	var path_count = $EnemyPaths.get_child_count()
#	var path = $EnemyPaths.get_children()[randi() % path_count]
#	follow = PathFollow2D.new()
#	path.add_child(follow)
#	follow.loop = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	follow.offset += speed * delta
	position = follow.global_position
	if follow.unit_offset > 1:
		queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_GunTimer_timeout():
	shoot_pulse(3, .15)
	

func _on_Enemy_body_entered(body):
	if body.name == "Player":
		pass 
	explode()
