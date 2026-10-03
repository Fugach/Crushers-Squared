extends Node

var player : CharacterBody2D
var main_node : Node2D
var WEAPON = preload("uid://d18mm0obf3dqi")
var cleared_rooms : Dictionary = {}

var current_slot_num : int = 1
var current_slot_node : Node2D = null

var slots : Dictionary[int, Node2D] = {
	0: null,
	1: null,
	2: null
}

var stats : Dictionary = {
	'time' = 0.0,
	'kills' = 0,
	'passed_layers' = 0,
	'lifes' = 3
}

func apply_CRT(body_material):
	if str(RenderingServer.get_current_rendering_method()) == "gl_compatibility":
		body_material.shader = preload("uid://dwmr157brsa3w")
		body_material.set_shader_parameter("brightness", 0.8)
		body_material.set_shader_parameter("contrast", 1.095)
		body_material.set_shader_parameter("saturation", 1.0)
		body_material.set_shader_parameter("gamma", 1.6)
		body_material.set_shader_parameter("curvature", 0.079)
		body_material.set_shader_parameter("vignette", 0.4)
		body_material.set_shader_parameter("scanline_strength", 0.634)
		body_material.set_shader_parameter("chroma_offset_px", 3.0)
		body_material.set_shader_parameter("jitter_px", 0.4)
		body_material.set_shader_parameter("wobble_px", 0.0)
		body_material.set_shader_parameter("tape_noise", 0.0)
		body_material.set_shader_parameter("tape_lines", 0.0)
		body_material.set_shader_parameter("roll_speed", 0.3)
		body_material.set_shader_parameter("roll_strength", 0.22)
		body_material.set_shader_parameter("glow_strength", 1.5)
		body_material.set_shader_parameter("glow_threshold", 0.05)
	elif str(RenderingServer.get_current_rendering_method()) == "forward_plus":
		body_material.shader = preload("uid://difxyhauojrf4")
		body_material.set_shader_parameter("resolution", Vector2(1280, 720))
		body_material.set_shader_parameter("warp_amount", 0.257)
		body_material.set_shader_parameter("noise_amount", 0.02)
		body_material.set_shader_parameter("vignette_amount", 1.0)
