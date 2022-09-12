extends CanvasLayer

signal start_game

class_name HUD
var paused:bool
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var lives_counter = [
	$MarginContainer/HBoxContainer/LivesCounter/L1,
	$MarginContainer/HBoxContainer/LivesCounter/L2,
	$MarginContainer/HBoxContainer/LivesCounter/L3]

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func show_message(message):
	$MessageLabel.text = message
	$MessageLabel.show()
	$MessageTimer.start()
	
func pause_message(state):
	if state:
		if not paused:
			$MessageLabel.text = "Pause"
			$MessageLabel.show()
	else:
		if paused:
			$MessageLabel.text = ""
			$MessageLabel.hide()
			
	paused = state
	pass	
func update_score(value):
	$MarginContainer/HBoxContainer/ScoreLabel.text = str(value).pad_zeros(5)

func update_lives(value):
	for item in range(3):
		lives_counter[item].visible = value > item
		
func update_timer(value):
	$MarginContainer/HBoxContainer/WaveTimer/time.text = str(value).pad_decimals(0).pad_zeros(2)
	
func update_wave(value):
	$MarginContainer/HBoxContainer/WaveTimer/timer_label.text = str("Wave "+ str(value).pad_zeros(2) + " : ")

func game_over():
	yield($MessageTimer,"timeout")
	$StartButton.show()

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")


func _on_MessageTimer_timeout():
	$MessageLabel.hide()
	$MessageLabel.text = ""
