extends Control

# nut de bat dau game
# dung tu khoa @export de keo tha gan ben ngoai editor
@export var btn_new_game:Button
# hoac dung @onready de gan node trong _ready() bang cach goi truc tiep node: $ButtonNewGame hoac get_node("ButtonNewGame") deu duoc
#@onready var btn_new_game:Button = $ButtonNewGame
# hien thi diem dat duoc
@export var score_label:Label
@export var high_score_label:Label
@export var your_score_label:Label
# am thanh
@export var input_sfx:AudioStreamPlayer
@export var eat_sfx:AudioStreamPlayer
@export var end_sfx:AudioStreamPlayer
@export var move_sfx:AudioStreamPlayer
# du lieu game: xem trong script data
@export var data:Node
# pixel scene
@export var pixel_ins:PackedScene

# kiem tra game ket thuc hay chua
var game_end:bool = true
# kiem tra game pase hay ko
var game_pause:bool = false
# kiem tra nut duoc nhan: 0 len, 1 xuong, 2 trai, 3 phai
var key_input:int = 3
# thoi gian de ran di chuyen: time += delta cho den khi time = snake_speed thi ran di chuyen
var time:float = 0
# toc do cua ran
var snake_speed:float = 0.3
# toa do di chuyen cua ran theo chieu ngang x, doc y
var pixel_x:int = 0
var pixel_y:int = 0
# lua tru toa do, vi tri cua cac diem pixel
var board:Array
# lua tru cac diem pixel
var pixel_board:Array
# thuc an ran co the an
var food:Sprite2D
# ran
var snake:Sprite2D
# chieu dai cua ran, diem an duoc = snake_size - 1
var snake_size:int = 1
# cac diem ran chua, moi mot diem la mot phan co the ran (cac diem moi) dung de xu ly viec ran di chuyen
var snake_body:Array = []
# cac diem ran chua, moi mot diem la mot phan co the ran (cac diem cu) dung de xu ly viec ran di chuyen
var temp_snake_body:Array = []
# diem bat dau cua ran
var snake_start_body:Array
# diem cuoi cua ran
var snake_end_body:Array
# xoa dinh viec ran doi chieu di chuyen: vi du ran dang di len, khi nhan di xuong ran se doi dau di chuyen xuong duoi.
var snake_change:bool = false

# xac dinh cac mau: tuong trung doi tuong: tuong, ran, diem,...
var wall_color:Color = Color.BLACK
var point_color:Color = Color.RED
var snake_head_color:Color = Color.BLUE
var snake_body_color:Color = Color.GREEN
var board_color:Color = Color.WHITE

# cac tin hieu xu ly, vi du: khi phin nhan thay doi, ket thuc game, ran an, diem duoc cong them
signal signal_key_changed(key:int)
signal signal_game_end()
signal signal_snake_eat()
signal signal_score_add()

# Called when the node enters the scene tree for the first time.
func _ready():
	# ket noi tat cac cac tin hieu
	# connect all signal
	# connect on_new_game
	btn_new_game.show()
	btn_new_game.connect("pressed",on_new_game)
	# connect on_game_end
	connect("signal_game_end",on_game_end)
	# connect input key pressed
	connect("signal_key_changed",on_key_changed)
	# connect snake eat
	connect("signal_snake_eat",on_snale_eat)
	# point add
	connect("signal_score_add",on_score_add)
	
	# tao data dua vao kich thuoc man hinh xac dinh hoac tuy chon x = 17, y = 11
	for i in round(size.y/64):
		board.append([])
		for j in round(size.x/64):
			board[i].append(0)
	pixel_board = board.duplicate(true)
	# them vao cac diem pixel dua data co duoc o tren
	for i in board.size():
		for j in board[i].size():
			var pixel:Sprite2D = pixel_ins.instantiate()
			$Board.add_child(pixel)
			pixel.modulate = board_color
			if j == 0:
				pixel.position.x = 32
				pixel_board[i][0] = pixel
			else:
				pixel.position.x = 32 + j * 64
				pixel_board[i][j] = pixel
			pixel.position.y = 32 + i * 64
	
	# create wall
	create_wall()
	# show score
	on_score_add()

# bat dau mot game moi
func on_new_game():
	# reset value
	time = 0
	snake_speed = 0.3
	snake_size = 1
	snake_body = []
	temp_snake_body = []
	snake_start_body = []
	snake_end_body = []
	snake_change = false
	
	# create board color
	for i in board.size():
		for j in board[i].size():
			pixel_board[i][j].modulate = board_color
	
	# create all object
	create_wall()
	create_snake()
	create_food()
	signal_score_add.emit()
	
	# create new game
	game_end = false
	game_pause = game_end
	btn_new_game.hide()

# khi game ket thuc: ran dam vao tuong, dam vao chinh no
func on_game_end():
	prints("")
	prints("Game End")
	prints("")
	end_sfx.play()
	game_end = true
	game_pause = game_end
	await get_tree().create_timer(1,false).timeout
	btn_new_game.show()

# tao tuong bao quanh
func create_wall():
	# create wall color
	# ngang
	for i in board[0].size():
		pixel_board[0][i].modulate = wall_color
		pixel_board[board.size()-1][i].modulate = wall_color
	# doc
	for i in board.size():
		pixel_board[i][0].modulate = wall_color
		pixel_board[i][board[0].size()-1].modulate = wall_color
	prints("")
	prints("Create Wall")
	prints("")

# tao ra ran ban dau
func create_snake():
	for i in snake_size:
		snake_body.append([])
	pixel_x = randi_range(int(pixel_board.size()/2-1),int(pixel_board.size()/2+1))
	pixel_y = randi_range(int(pixel_board[0].size()/2-1),int(pixel_board[0].size()/2+1))
	snake_body[0] = [pixel_x,pixel_y]
	temp_snake_body = snake_body
	prints("")
	prints("Create Snake____",snake_body[0])
	prints("")

# tao ra thuc an, khac voi vi tri cua ran, dong thoi tang toc do cua ran sau moi diem an duoc
func create_food():
	var ok_foods:Array
	for child in $Board.get_children():
		if child.modulate == Color(1,1,1,1):
			ok_foods.append(child)
	food = ok_foods.pick_random()
	food.modulate = point_color
	ok_foods.clear()
	snake_speed = snake_speed/100.0*98.0
	prints("")
	prints("Create Food____",food)
	prints("New Speed", snake_speed)
	prints("")

# xu ly cac phim duoc nhan de di chuyen ran
func _unhandled_key_input(event):
	if Input.is_action_pressed("ui_up"):
		signal_key_changed.emit(0)
	elif Input.is_action_pressed("ui_down"):
		signal_key_changed.emit(1)
	elif Input.is_action_pressed("ui_left"):
		signal_key_changed.emit(2)
	elif Input.is_action_pressed("ui_right"):
		signal_key_changed.emit(3)

# xu ly phim menu
func _input(event):
	# new game
	if event.is_pressed() and game_end == true and btn_new_game.visible == true:
		game_end = false
		on_new_game()
	# pause game
	elif Input.is_key_label_pressed(KEY_ESCAPE) and game_end == false:
		if game_pause == false:
			game_pause = true
			btn_new_game.visible = game_pause
		else:
			game_pause = false
			btn_new_game.visible = game_pause

# khi co phim duoc nhan
func on_key_changed(key:int):
	input_sfx.play()
	# chi xu ly khi nhan phim khac
	if key != key_input:
		if snake_body.size() > 1:
			# truong hop khi ran doi dau
			if (key < 2 and key_input < 2) or (key > 1 and key_input > 1):
				snake_change = true
			else:
				snake_change = false
			# xu ly huong di chuyen khi ran doi dau
			if snake_change == true:
				var end0:Array = snake_body[snake_body.size()-2]
				var end1:Array = snake_body[snake_body.size()-1]
				# doc
				if end0[1] == end1[1]:
					if end0[0] == board[0].size()-1 and end1[0] == 0:
						key = 0
					elif end0[0] == 0 and end1[0] == board[0].size()-1:
						key = 1
					elif end0[0] > end1[0]:
						key = 0
					elif end0[0] < end1[0]:
						key = 1
				# ngang
				elif end0[0] == end1[0]:
					if end0[1] == 0 and end1[1] == board.size()-1:
						key = 2
					elif end0[1] == board.size()-1 and end1[1] == 0:
						key = 3
					elif end0[1] > end1[1]:
						key = 2
					elif end0[1] < end1[1]:
						key = 3
				
				var temp0:Array = []
				var temp1:Array = []
				for i in range(snake_body.size()-1,-1,-1):
					temp0.append(snake_body[i])
					temp1.append(temp_snake_body[i])
				snake_body = temp0.duplicate(true)
				temp_snake_body = temp1.duplicate(true)
				temp0 = []
				temp1 = []
				pixel_x = snake_body[0][0]
				pixel_y = snake_body[0][1]
		key_input = key

# khi ran an: them 1 phan bo phan cho ran, tao 1 diem moi tren map
func on_snale_eat():
	eat_sfx.play()
	# vi tri bo phan them vao
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
	if body_x < 0:
		body_x = remap(body_x,-(board.size()-1),-1,1,board.size()-1)
	if body_y < 0:
		body_y = remap(body_y,-(board[0].size()-1),-1,1,board[0].size()-1)
	# them data cho phan bo phan
	snake_size += 1
	snake_end_body = [body_x,body_y]
	snake_body.append(snake_end_body)
	temp_snake_body.append(snake_body[0])
	# tao 1 diem moi tren map
	create_food()
	prints("")
	prints("Snake Eat",snake_body,temp_snake_body)
	prints("")

# cong them diem
func on_score_add():
	# hien so diem cao nhat tung dat duoc
	# goi data da luu len: neu diem dat duoc cao hon diem da luu, thi luu vao
	var score:int = snake_size - 1
	data.data = data.get_data()
	if score > data.data.record:
		data.data.record = score
		high_score_label.text = "New Record: " + str(score)
		data.save_data(data.data)
	else:
		score = data.data.record
		high_score_label.text = "Record: " + str(score)
	# hien so diem co duoc
	score_label.text = "Score: " + str(snake_size - 1)
	your_score_label.text = "Score: " + str(snake_size - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# xu ly ran di chuyen
func _process(delta):
	# chi hoat dong khi game dang chay: game_end = false
	if game_end == false and game_pause == false:
		# thoi gian de ran di chuyen: time += delta cho den khi time >= snake_speed thi ran di chuyen
		time += delta
		# ran di chuyen
		if time >= snake_speed:
			move_sfx.play()
			# tim vi tri dau moi cua ran sau khi di chuyen
			# dua vao phim duoc nhan moi nhan
			match key_input:
				0:
					pixel_x -= 1
				1:
					pixel_x += 1
				2:
					pixel_y -= 1
				3:
					pixel_y += 1
			
			if pixel_x > board.size()-1 or abs(pixel_x) > board.size()-1:
				pixel_x = 0
			elif pixel_x < 0:
				pixel_x = remap(pixel_x,-(board.size()-1),-1,1,board.size()-1)
			
			if pixel_y > board[0].size()-1 or abs(pixel_y) > board[0].size()-1:
				pixel_y = 0
			elif pixel_y < 0:
				pixel_y = remap(pixel_y,-(board[0].size()-1),-1,1,board[0].size()-1)
			
			# tim duoc vi tri dau moi cua ran
			snake_body[0] = [pixel_x, pixel_y]
			snake_start_body = snake_body[0]
			
			# xac dinh dau ran co va cham voi doi tuong nao khong
			var object:Sprite2D = pixel_board[snake_body[0][0]][snake_body[0][1]]
			# truong hop ran chet
			if (object.modulate == snake_body_color and snake_change == false) or object.modulate == wall_color:
				signal_game_end.emit()
			# truong hop ran an
			if object.modulate == point_color:
				signal_snake_eat.emit()
				signal_score_add.emit()
			
			# tu diem dau xac dinh cac diem con lai cua ran dua vao cac diem cu temp_snake_body
			# create all body data when snake_size > 1
			if snake_size > 1:
				for i in snake_size:
					# xac dinh cac diem con lai
					if i > 0:
						snake_body[i] = temp_snake_body[i-1]
			
			# xoa diem cuoi cua ran: vi ran di chuyen den diem moi
			# deleta end body
			snake_end_body = [temp_snake_body[temp_snake_body.size()-1][0],temp_snake_body[temp_snake_body.size()-1][1]]
			snake = pixel_board[snake_end_body[0]][snake_end_body[1]]
			snake.modulate = board_color
			
			# hien thi mau cua ran: tao ra hieu ung ran di chuyen
			# create head, body display
			for i in snake_body.size():
				if snake_body[i].size() > 0:
					snake = pixel_board[snake_body[i][0]][snake_body[i][1]]
					if i == 0:
						snake.modulate = snake_head_color
					else:
						snake.modulate = snake_body_color
			
			# lua data da di chuyen cua ran
			temp_snake_body = snake_body.duplicate(true)
			
			# ket thuc viec ran di chuyen
			time = 0
