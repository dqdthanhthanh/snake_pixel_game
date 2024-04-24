extends Control

@export var pixel_ins:PackedScene

var old_key_input:int = 3
var key_input:int = 3
var time:float
var snake_speed:float = 0.2
var board:Array
var pixel_board:Array
var point:Sprite2D
var move_x:int = 0
var move_y:int = 0
var snake:Sprite2D
var snake_size:int = 5
var snake_body:Array = []
var count_body_create:int = snake_size-2
var temp_snake_body:Array
var snake_start_body:Array

var snake_body_create:int = 0
var snake_turn_pos:Array
var snake_end_body:Array

# Called when the node enters the scene tree for the first time.
func _ready():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if time > snake_speed:
		prints("_____")
		snake_body_create += 1
		
		# create head
		snake_body[0] = [move_y, move_x]
		
		# eat
		var point:Sprite2D = pixel_board[snake_body[0][0]][snake_body[0][1]]
		if point.modulate == Color.RED:
			create_point()
			snake_size += 1
			snake_body.append(snake_end_body)
			temp_snake_body.append(snake_end_body)
			
		
		match key_input:
			0:
				move_y -= 1
			1:
				move_y += 1
			2:
				move_x -= 1
			3:
				move_x += 1
		
		if move_x > board[0].size()-1 or abs(move_x) > board[0].size()-1:
			move_x = 0
		if move_y > board.size()-1 or abs(move_y) > board.size()-1:
			move_y = 0
		
		# create head
		prints("0 create head")
		snake_start_body = snake_body[0]
		snake = pixel_board[snake_start_body[0]][snake_start_body[1]]
		
		if snake_body_create > 1:
			prints("1 create first body")
			snake_body[1] = snake_turn_pos
			snake = pixel_board[snake_turn_pos[0]][snake_turn_pos[1]]
		
		prints("snake_body", snake_body)
		
		if snake_body_create > 2 and snake_body_create-1 < snake_size:
			prints("2 create new body")
			var temp_count = count_body_create
			for i in snake_size:
				if i > 1 and count_body_create > 0:
					if snake_body[i].size() == 0: 
						count_body_create -= 1
					var s:int = 1
					var body_y:int = snake_body[i-1][0]
					var body_x:int = snake_body[i-1][1]
					
					match key_input:
						0:
							body_y += s
						1:
							body_y -= s
						2:
							body_x += s
						3:
							body_x -= s
					
					if body_y > board.size()-1 or abs(body_y) > board.size()-1:
						body_y = 0
						move_y = 0
					if body_x > board[0].size()-1 or abs(body_x) > board[0].size()-1:
						body_x = 0
						move_x = 0
					snake_body[i] = [body_y,body_x]
					if temp_count != count_body_create:
						break
		prints("snake_body_create",snake_body_create)
		
		# recreate all body
		if snake_body_create > snake_size:
			for i in snake_size:
				if i > 1 and snake_body[i].size() > 0:
					snake_body[i] = temp_snake_body[i-1]
			# delete_end_body
			snake_end_body = [temp_snake_body[temp_snake_body.size()-1][0],temp_snake_body[temp_snake_body.size()-1][1]]
			snake = pixel_board[snake_end_body[0]][snake_end_body[1]]
			snake.modulate = Color.WHITE
		
		temp_snake_body = snake_body.duplicate(true)
		
		# create_head, body
		for n in snake_body.size():
			if snake_body[n].size() > 0:
				snake = pixel_board[snake_body[n][0]][snake_body[n][1]]
				if n == 0:
					snake.modulate = Color.BLUE
				else:
					snake.modulate = Color.GREEN
		
		prints("snake_body", snake_body)
		prints("temp_snake_body", temp_snake_body)
		
		# snake_turn_pos
		snake_turn_pos = snake_body[0]
		snake_body[1] = snake_turn_pos
	
	if time > snake_speed:
		time = 0

func create_snake():
	"""
	snake_size = 3
	
	snake_body_create = 1
	tao dau
	
	snake_body_create = 2
	tao dau
	than 1 = snake_turn_pos
	
	snake_body_create = snake_size
	tao dau
	than 1 = snake_turn_pos
	duoi = than 1
	
	snake_body_create > snake_size
	tao dau
	than 1 = snake_turn_pos
	duoi = than 1
	xoa duoi
	
	"""
	for i in snake_size:
		snake_body.append([])
	temp_snake_body = snake_body
	move_y = randi_range(int(pixel_board.size()/2-1),int(pixel_board.size()/2+1))
	move_x = randi_range(int(pixel_board[0].size()/2-1),int(pixel_board[0].size()/2+1))

func create_point():
	if point != null:
		point.modulate = Color.WHITE
	point = create_obj()
	point.modulate = Color.RED

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		create_snake()
		create_point()
	
	#if (Input.is_action_pressed("ui_up")
	#or Input.is_action_pressed("ui_down")
	#or Input.is_action_pressed("ui_left")
	#or Input.is_action_pressed("ui_right")):
		#pass
	
	if Input.is_action_pressed("ui_up"):
		if key_input != 0:
			if key_input > 1:
				move_x = snake_body[0][1]
			elif key_input < 2:
				snake = pixel_board[snake_body[0][0]][snake_body[0][1]]
				snake.modulate = Color.WHITE
				move_x = snake_body[snake_body.size()-1][1]
			move_y = snake_body[snake_body.size()-1][0]
			snake_turn_pos = [move_y,move_x]
			key_input = 0
	elif Input.is_action_pressed("ui_down"):
		if key_input != 1:
			if key_input > 1:
				move_x = snake_body[0][1]
			elif key_input < 2:
				snake = pixel_board[snake_body[0][0]][snake_body[0][1]]
				snake.modulate = Color.WHITE
				move_x = snake_body[snake_body.size()-1][1]
			move_y = snake_body[snake_body.size()-1][0]
			snake_turn_pos = [move_y,move_x]
			key_input = 1
	elif Input.is_action_pressed("ui_left"):
		if key_input != 2:
			if key_input > 1:
				move_y = snake_body[snake_body.size()-1][0]
				snake = pixel_board[snake_body[0][0]][snake_body[0][1]]
				snake.modulate = Color.WHITE
			elif key_input < 2:
				move_y = snake_body[0][0]
			move_x = snake_body[snake_body.size()-1][1]
			snake_turn_pos = [move_y,move_x]
			key_input = 2
	elif Input.is_action_pressed("ui_right"):
		if key_input != 3:
			if key_input > 1:
				move_y = snake_body[snake_body.size()-1][0]
				snake = pixel_board[snake_body[0][0]][snake_body[0][1]]
				snake.modulate = Color.WHITE
			elif key_input < 2:
				move_y = snake_body[0][0]
			move_x = snake_body[snake_body.size()-1][1]
			snake_turn_pos = [move_y,move_x]
			key_input = 3

func create_obj() -> Sprite2D:
	var i = randi_range(0,pixel_board.size()-1)
	var j = randi_range(0,pixel_board[0].size()-1)
	var obj:Sprite2D = pixel_board[i][j]
	return obj
