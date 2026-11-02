extends Node

var player : CharacterBody2D
var main_node : Node2D
var slots_node : Control

var WEAPON = preload("uid://d18mm0obf3dqi")
var ROCKET = preload("uid://cfex0tmkaj6q4")
var FLAME = preload("uid://b031wyq3p3dvw")
var BULLET = preload("uid://csr8w1qcnqlbd")


const DEFAULT = preload("uid://bemiao6fdt5rx")
const DEFAULT_CLICKED = preload("uid://byb7c1x4ap1xh")
const GOOD = preload("uid://bf4lredv4dfre")
const BAD = preload("uid://bkdx86pdaby8c")
const GRAB = preload("uid://by4nbpa3o7ovs")
const HITSCAN = preload("uid://dxr0dlvqqj1xl")
const NO = preload("uid://d1jfg55xa3kqg")
const OTHER = preload("uid://blyc8fodhovfi")
const POINTER = preload("uid://cm158u7avgsfw")
const POINTER_CLICKED = preload("uid://djdndjxkuh6rs")
const SPLASH = preload("uid://bgvnas1i4cu2")
const TEXT = preload("uid://bkqkaei3hxj2l")
const USABLE = preload("uid://bm8nku3t8smrp")
const WAIT = preload("uid://c2f5luxocn7rb")

var cleared_rooms : Dictionary = {}

var stats : Dictionary = {
	'time' = 0.0,
	'kills' = 0,
	'passed_layers' = 0,
	'lifes' = 3
}

func _init() -> void:
	Input.set_custom_mouse_cursor(DEFAULT, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(TEXT, Input.CURSOR_IBEAM, Vector2(7 * 3, 6 * 3))
	Input.set_custom_mouse_cursor(POINTER, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(HITSCAN, Input.CURSOR_CROSS)
	Input.set_custom_mouse_cursor(WAIT, Input.CURSOR_WAIT)
	Input.set_custom_mouse_cursor(WAIT, Input.CURSOR_BUSY)

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
