extends Node2D

export (PackedScene) var rock
export (PackedScene) var enemy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screensize = Vector2()
var level = 0
var score = 0
var wave = 0

var playing = false

func new_game():
	for r in $Rocks.get_children():
		r.queue_free()
	
	level = 0
	score = 0
	wave = 0
	$HUD.update_score(score)
	
	$Player.show()
	$Player.start($SpawnPlayer.position)
	
	$HUD.show_message("Get Ready!")
	yield($HUD/MessageTimer,"timeout")
	playing = true
	new_level()

func new_level():
	level += 1
	wave +=1
	$HUD.show_message("Wave %s"% level)
	$HUD.update_wave(wave)
	yield($HUD/MessageTimer,"timeout")
	
	for i in range(level):
		spawn_rock(3)
	
	$WaveTimer.start()
		
	$EnemyTimer.wait_time = rand_range(5,10)
	$EnemyTimer.start()
	
	

func game_over():
	playing = false
	$WaveTimer.stop()
	
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
		$HUD.pause_message(true)
		$EnemyTimer.set_paused(true)
		$WaveTimer.set_paused(true)
	else:
		$HUD.pause_message(false)
		$EnemyTimer.set_paused(false)
		$WaveTimer.set_paused(false)
		
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
	$HUD.update_timer($WaveTimer.time_left)
	pass

func _on_Player_shoot(bullet,post,dir):
	var b = bullet.instance()
	b.start(post,dir)
	add_child(b)

func _on_Enemy_exploded():
	score +=25
	$HUD.update_score(score)
	pass
func _on_Rock_exploded(size,radius,pos,vel):
	if(size <= 1):
		score += 10
		$HUD.update_score(score)
		return
		
	score += 5
	$HUD.update_score(score)
	for offset in [-1,1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size-1,newpos,newvel)


func _on_EnemyTimer_timeout():
	var path_count = $EnemyPaths.get_child_count()
	var path = $EnemyPaths.get_children()[randi() % path_count]
	
	var e = enemy.instance()
	e.spawn(path,$Player)
	e.connect("shoot", self,"_on_Player_shoot")
	e.connect("exploded", self,"_on_Enemy_exploded")
	e.show()
	
	add_child(e)
	$EnemyTimer.wait_time = rand_range(20,40)
	$EnemyTimer.start()


func _on_WaveTimer_timeout():
	new_level()
	pass # Replace with function body.
