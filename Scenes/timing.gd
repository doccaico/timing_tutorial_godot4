extends Node2D

@onready var tile = $Tile
@onready var info = $Info

const DARK_GREEN = Vector2i(0, 0)
const DARK_YELLOW = Vector2i(1, 0)
const DARK_RED = Vector2i(2, 0)
const BAR = Vector2i(3, 0)
const OUT_OF_BOUNDS = Vector2i(-1, -1)
const FLASH_COUNT = 3
const FLASH_DURATION = 0.05

var bars: Array[Vector2i]
var dir_x: int
var speed: float
var duration: float

func _ready() -> void:
	bars = [
		Vector2i(4, 4),
		Vector2i(4, 5),
		Vector2i(4, 6),
		Vector2i(4, 7)
	]
	dir_x = 1
	speed = 21.0
	duration = 0.0
	$Info.hide()


func _process(delta) -> void:
	duration += delta
	if duration >= (1.0 / speed):
		# change current bar
		var bg_coords = tile.get_cell_atlas_coords(0, bars[0])
		for i in range(4):
			tile.set_cell(1, bars[i], 0, bg_coords)
		
		# change next bar
		for i in range(4):
			bars[i].x += dir_x
		for b in bars:
			tile.set_cell(1, b, 0, BAR)
		
		# changes a direction of the bar if bound check is true
		if dir_x == 1:
			var next_coords = tile.get_cell_atlas_coords(0, Vector2i(bars[0].x + 1, bars[0].y))
			if next_coords == OUT_OF_BOUNDS:
				dir_x = -1
		elif dir_x == -1:
			var next_coords = tile.get_cell_atlas_coords(0, Vector2i(bars[0].x - 1, bars[0].y))
			if next_coords == OUT_OF_BOUNDS:
				dir_x = 1
		
		duration = 0.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("BUTTON_LEFT"):
		var coords = tile.get_cell_atlas_coords(0, bars[0])
		if coords == DARK_GREEN:
			info.text = "MISS..."
			flash(2)
		elif coords == DARK_YELLOW:
			info.text = "HIT"
			flash(3)
		elif coords == DARK_RED:
			info.text = "CRITICAL"
			flash(4)
		
		var tween = create_tween()
		info.show()
		tween.parallel().tween_property(info, "modulate:a", 0, 0.7)
		tween.parallel().tween_property(info, "position:y", 226, 0.7)
		await tween.finished
		info.hide()
		info.modulate.a = 1
		info.position.y = 330


func flash(layer: int):
	var tree = get_tree()
	for i in FLASH_COUNT:
		tile.set_layer_enabled(layer, true)
		await tree.create_timer(FLASH_DURATION).timeout
		tile.set_layer_enabled(layer, false)
		await tree.create_timer(FLASH_DURATION).timeout
