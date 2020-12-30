extends Node2D

export (PackedScene) var rock
export (PackedScene) var enemy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screensize = Vector2()
var level = 0
var score = 0

var playing = false

func new_game():
	for r in $Rocks.get_children():
		r.queue_free()
	level = 0
	score = 0
	$HUD.update_score(score)
	$Player.show()
	$Player.start($SpawnPlayer.position)
	
	$HUD.show_message("Get Ready!")
	yield($HUD/MessageTimer,"timeout")
	playing = true
	new_level()

func new_level():
	level += 1
	$HUD.show_message("Wave %s"% level)
	for i in range(level):
		spawn_rock(3)
	$EnemyTimer.wait_time = rand_range(5,10)
	$EnemyTimer.start()

func game_over():
	playing = false
	$HUD.show_message("Game Over!")
	$HUD.game_over()

func spawn_rock(size,pos=null,vel=null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi())
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(0,2*PI))*rand_range(100,150)
	
	var r = rock.instance()
	r.screensize = screensize
	r.start(pos,vel,size)
	r.connect("exploded",self,"_on_Rock_exploded")
	$Rocks.add_child(r)

func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
	
	if get_tree().paused:
		$HUD/MessageLabel.text = "Pause"
		$HUD/MessageLabel.show()
	else:
		$HUD/MessageLabel.text = ""
		$HUD/MessageLabel.hide()
		
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize =screensize
	$Player.hide()
	for i in range(3):
		spawn_rock(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playing and $Rocks.get_child_count() == 0:
		new_level()


func _on_Player_shoot(bullet,post,dir):
	var b = bullet.instance()
	b.start(post,dir)
	add_child(b)
	
func _on_Rock_exploded(size,radius,pos,vel):
	if(size <= 1):
		return
	
	for offset in [-1,1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size-1,newpos,newvel)


func _on_EnemyTimer_timeout():
	var e = enemy.instance()
	add_child(e)
	e.target = $Player
	e.connect("shoot", self,"_on_Player_shoot")
	e.show()
	$EnemyTimer.wait_time = rand_range(20,40)
	$EnemyTimer.start()
