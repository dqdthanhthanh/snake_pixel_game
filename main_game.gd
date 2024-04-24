extends Control

@export var pixel_ins:PackedScene

var game_end:bool = false
var snake_skill:bool = false
var key_input:int = 3
var time:float
var snake_speed:float = 0.1
var board:Array
var pixel_board:Array
var point:Sprite2D
var pixel_x:int = 0
var pixel_y:int = 0
var snake:Sprite2D
var snake_size:int = 1
var snake_body:Array = []
var temp_snake_body:Array
var snake_start_body:Array
var snake_end_body:Array

signal key_changed(key:int)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("key_changed",on_key_changed)
	# create board
	for i in 11:
		board.append([])
		for j in 17:
			board[i].append(0)
	pixel_board = board.duplicate(true)
	# add_pixel
	for i in board.size():
		var pixel_y:Sprite2D = preload("res://pixel.tscn").instantiate()
		for j in board[i].size():
			var pixel:Sprite2D = preload("res://pixel.tscn").instantiate()
			$Board.add_child(pixel)
			if j == 0:
				pixel.position.x = 32
				pixel_board[i][0] = pixel
			else:
				pixel.position.x = 32 + j * 64
				pixel_board[i][j] = pixel
			pixel.position.y = 32 + i * 64
	create_snake()
	create_point()

func on_key_changed(key:int):
	prints("key_________",key,key_input,"_____")
	# di chuyen doc
	if key != key_input:
		if snake_body.size() > 1:
			var temp:Array
			if (key < 2 and key_input < 2) or (key > 1 and key_input > 1):
				prints("snake_skill_________",key,key_input,"_____",true)
				snake_skill = true
			else:
				prints("snake_skill_________",key,key_input,"_____",false)
				snake_skill = false
			if snake_skill == true:
				temp = snake_body[0]
				snake_body[0] = snake_body[snake_body.size()-1]
				snake_body[snake_body.size()-1] = temp
		key_input = key

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if time > snake_speed and game_end == false:
		snake_start_body = [pixel_x, pixel_y]
		
		match key_input:
			0:
				pixel_x -= 1
			1:
				pixel_x += 1
			2:
				pixel_y -= 1
			3:
				pixel_y += 1
		
		if pixel_y > board[0].size()-1 or abs(pixel_y) > board[0].size()-1:
			pixel_y = 0
		if pixel_x > board.size()-1 or abs(pixel_x) > board.size()-1:
			pixel_x = 0
		
		snake_body[0] = [pixel_x, pixel_y]
		#prints("")
		#prints("Snake Move",snake_body,temp_snake_body)
		
		# eat
		var point:Sprite2D = pixel_board[snake_body[0][0]][snake_body[0][1]]
		if point.modulate == Color.GREEN and snake_skill == false:
			game_end = true
			prints("")
			prints("Game End")
			prints("")
		if point.modulate == Color.RED:
			var s:int = 1
			var body_x:int = pixel_x
			var body_y:int = pixel_y
			
			match key_input:
				0:
					body_y += s
				1:
					body_y -= s
				2:
					body_x += s
				3:
					body_x -= s
			
			if body_x > board.size()-1 or abs(body_x) > board.size()-1:
				body_x = 0
				pixel_x = 0
			if body_y > board[0].size()-1 or abs(body_y) > board[0].size()-1:
				body_y = 0
				pixel_y = 0
			
			snake_size += 1
			snake_end_body = [body_x,body_y]
			snake_body.append(snake_end_body)
			temp_snake_body.append(snake_body[0])
			create_point()
			prints("")
			prints("Snake Eat",snake_body,temp_snake_body)
			prints("")
		
		# create all body data when snake_size > 1
		if snake_size > 1:
			for i in snake_size:
				if i > 0:
					snake_body[i] = temp_snake_body[i-1]
		
		# deleta end body
		snake_end_body = [temp_snake_body[temp_snake_body.size()-1][0],temp_snake_body[temp_snake_body.size()-1][1]]
		snake = pixel_board[snake_end_body[0]][snake_end_body[1]]
		snake.modulate = Color.WHITE
		
		temp_snake_body = snake_body.duplicate(true)
		
		# create head, body display
		for n in snake_body.size():
			if snake_body[n].size() > 0:
				snake = pixel_board[snake_body[n][0]][snake_body[n][1]]
				if n == 0:
					snake.modulate = Color.BLUE
				else:
					snake.modulate = Color.GREEN
		
		#prints("snake_body", snake_body)
		#prints("temp_snake_body", temp_snake_body)
	
	if time > snake_speed:
		time = 0

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		create_snake()
		create_point()
	
	if Input.is_action_pressed("ui_up"):
		key_changed.emit(0)
	elif Input.is_action_pressed("ui_down"):
		key_changed.emit(1)
	elif Input.is_action_pressed("ui_left"):
		key_changed.emit(2)
	elif Input.is_action_pressed("ui_right"):
		key_changed.emit(3)

func create_snake():
	prints("")
	for i in snake_size:
		snake_body.append([])
	pixel_x = randi_range(int(pixel_board.size()/2-1),int(pixel_board.size()/2+1))
	pixel_y = randi_range(int(pixel_board[0].size()/2-1),int(pixel_board[0].size()/2+1))
	snake_body[0] = [pixel_x,pixel_y]
	temp_snake_body = snake_body
	prints("Create Snake____",snake_body[0])
	prints("")

func create_point():
	prints("")
	var ok_point:Array
	for child in $Board.get_children():
		if child.modulate != Color.GREEN:
			ok_point.append(child)
	point = ok_point.pick_random()
	point.modulate = Color.RED
	ok_point.clear()
	prints("Create Point____",point)
	prints("")
