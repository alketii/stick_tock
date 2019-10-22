extends Node2D

onready var stick = get_node("stick")
onready var theguy = get_node("theguy")
onready var cam = get_node("camera")
onready var bg = get_node("hud/bg")
onready var scores_lbl = get_node("hud/score")
onready var highscore_lbl = get_node("hud/highscore")

var stick_size = 4
var allow_action = true
var action_pressed = false
var stick_rotate = false

var rotd_tmp = 0
var action_point = 700
var walk = false

const mnt_p = preload("res://mountain.tscn")
var mnt_x = 200
var mnt_current = 0
var mnt_size = Vector2(0,0)

var passed = true
var fall = false

var cam_x = 0
var cam_follow = false

var walk_pressed = false
var upsidedown = false

var score = 0
onready var config = ConfigFile.new()
var highscore = 0

func _ready():
	if not global.show_credits:
		get_node("hud/open_url").queue_free()
	config.load("user://settings.cfg")
	highscore = config.get_value("general","highscore",0)
	highscore_lbl.set_text(str(highscore))
	OS.set_window_position(Vector2(740,0))
	randomize()
	bg.set_frame(randi()%2)
	create_mountain()
	set_fixed_process(true)
	
func _fixed_process(delta):
	if Input.is_action_pressed("action"):
		if allow_action:
			action_pressed = true
			stick_size += 8
			stick.set_region_rect(Rect2(0,0,4,stick_size))
			stick.set_offset(Vector2(0,-stick_size/2))
			if stick_size >= 720:
				allow_action = false
		
		else:
			if walk and not walk_pressed:
				walk_pressed = true
				if upsidedown:
					upsidedown = false
					theguy.get_node("sprites").set_flip_v(false)
					theguy.set_pos(theguy.get_pos() - Vector2(0,32))
				else:
					upsidedown = true
					theguy.get_node("sprites").set_flip_v(true)
					theguy.set_pos(theguy.get_pos() + Vector2(0,32))
		
		if global.show_credits:
			global.show_credits = false
			get_node("hud/open_url").queue_free()
		
	else:
		walk_pressed = false
		if action_pressed:
			allow_action = false
			action_pressed = false
			rotd_tmp = 0
			stick_rotate = true
			#printt("stc",stick_size)
	
	if stick_rotate:
		if rotd_tmp != -90:
			rotd_tmp -= 3
			stick.set_rotd(rotd_tmp)
		else:
			stick_rotate = false
			walk = true
			if stick_size >= mnt_size.x and stick_size <= mnt_size.y:
				passed = true
			else:
				passed = false
			
	if walk:
		theguy.move(Vector2(5,0))
		#theguy.get_node("sprites").set_frame(int(theguy.get_pos().x) % 6)
		if passed:
			if not upsidedown:
				if theguy.get_pos().x >= mnt_current-24:
					walk = false
					stick.set_offset(Vector2(0,0))
					stick.set_pos(Vector2(mnt_current-2,702))
					stick_size = 0
					stick.set_rotd(0)
					stick.set_region_rect(Rect2(0,0,0,0))
					create_mountain()
					score += 1
					scores_lbl.set_text(str(score))
					cam_follow = true
			else:
				if theguy.get_pos().x-stick.get_pos().x >= mnt_size.x -16:
					walk = false
					fall = true
		else:
			if not upsidedown:
				if theguy.get_pos().x >= stick.get_pos().x+stick_size:
					walk = false
					fall = true
			else:
				if stick_size < mnt_size.x and theguy.get_pos().x >= stick.get_pos().x+stick_size-24:
					walk = false
					fall = true
				else:
					if theguy.get_pos().x-stick.get_pos().x >= mnt_size.x -16:
						walk = false
						fall = true
	
	if cam_follow:
		if cam.get_pos().x < theguy.get_pos().x-100:
			cam.move(Vector2(15,0))
		else:
			cam_follow = false
			allow_action = true
	
	if fall:
		if theguy.get_pos().y < 1320:
			theguy.move(Vector2(0,10))
		else:
			if score > highscore:
				config.set_value("general","highscore",score)
				config.save("user://settings.cfg")
			get_tree().reload_current_scene()

		if rotd_tmp > -180:
			rotd_tmp -= 5
			stick.set_rotd(rotd_tmp)
	
func create_mountain():
	var mnt = mnt_p.instance()
	var mnt_width = (randi() % 100) + 32
	mnt.set_offset(Vector2(mnt_width/2,0))
	mnt.set_region_rect(Rect2(0,0,mnt_width,800))
	mnt_x += (randi() % 570) + 32
	mnt.set_pos(Vector2(mnt_x,1100))
	mnt_current = mnt_x + mnt_width
	mnt_size = Vector2(mnt_x-stick.get_pos().x,mnt_x+mnt_width-stick.get_pos().x)
	add_child(mnt)
	if mnt_x > 200:
		create_cherry()
	mnt_x += mnt_width

func create_cherry():
	var create = randi()% 2
	if create == 1:
		pass

func _on_open_url_pressed():
	OS.shell_open("https://alketii.github.io")
