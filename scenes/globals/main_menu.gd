extends Node2D
signal start_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	var resize_x = get_viewport().get_visible_rect().size.x/$HUD/BackGround.get_rect().size.x
	$HUD/BackGround.set_scale(Vector2(resize_x,resize_x))
	#var resize_x = get_viewport().get_visible_rect().size.x/$HUD.get_rect().size.x
	#$HUD.set_scale(Vector2(resize_x,resize_x))
	#pass # Replace with function body.
	$HUD.custom_minimum_size = get_viewport().get_visible_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	#print("start_button_pressed")
	var mode  = ''
	if $HUD/GameTypes/RelaxGame.is_pressed():
		mode = 'relax'
	if $HUD/GameTypes/MindGame.is_pressed():
		mode = 'mind'
	if $HUD/GameTypes/Race.is_pressed():
		mode = 'race'
	emit_signal("start_button_pressed", mode)
	pass # Replace with function body.
