extends ScrollContainer
class_name SwipeMenu


@export var card_scenes: Array[PackedScene]
@export_range(0.0, 2.0, 0.001, "or_greater") var calm_time := 0.5
@export_range(0, 100, 1, "or_greater", "suffix:px") var separation := 20
@export_range(0, 2160, 1, "or_less", "or_greater", "suffix:px") var first_offset := 400
@export var transition: Tween.TransitionType = Tween.TRANS_BACK
@export var ease: Tween.EaseType = Tween.EASE_OUT


@onready var center_container: CenterContainer = $CenterContainer
@onready var card_container: HBoxContainer = $CenterContainer/MarginContainer/CardContainer
@onready var margin_container: MarginContainer = $CenterContainer/MarginContainer

@onready var container_size: Vector2 = center_container.size


var selected_item_idx := 0
var scroll_target := 0.0

var cards: Array[Control] = []
var card_centers: Array[float] = []

var scroller: Tween


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	
	card_container.set("theme_override_constants/separation", separation)
	
	for card_scene in card_scenes:
		var card: Control = card_scene.instantiate()
		cards.push_back(card)
		card_container.add_child(card)
	
	await get_tree().process_frame
	
	var viewport_width: float = get_viewport_rect().size.x
	margin_container.set("theme_override_constants/margin_left", viewport_width)
	margin_container.set("theme_override_constants/margin_right", viewport_width)
	
	var margin_left: float = margin_container.get("theme_override_constants/margin_left")
	var margin_right: float = margin_container.get("theme_override_constants/margin_right")
	
	var offset := margin_left - first_offset
	for i in range(cards.size()):
		var card := cards[i]
		var center := offset + 0.5 * card.size.x
		
		card_centers.push_back(center)
		offset += card.size.x + separation
	
	start_scroll()


func _process(delta: float) -> void:
	if not scroller.is_running():
		var min_distance := 1e12
		var card_idx := 0
		
		for i in range(card_centers.size()):
			var center := card_centers[i]
			var cur_distance := absf(scroll_horizontal - center)
			
			if cur_distance < min_distance:
				min_distance = cur_distance
				card_idx = i
		
		selected_item_idx = card_idx


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		selected_item_idx = clampi(selected_item_idx - 1, 0, selected_item_idx)
		restart_scroll()
	
	elif event.is_action_pressed("ui_right"):
		var children_count := card_container.get_children().size()
		selected_item_idx = clampi(selected_item_idx + 1, 0, children_count - 1)
		restart_scroll()


func start_scroll() -> void:
	scroll_target = card_centers[selected_item_idx]
	
	scroller = get_tree().create_tween()
	scroller\
		.tween_property(self, "scroll_horizontal", scroll_target, calm_time)\
		.from(scroll_horizontal)\
		.set_trans(transition)\
		.set_ease(ease)


func stop_scroll() -> void:
	scroller.kill()


func restart_scroll() -> void:
	stop_scroll()
	start_scroll()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			stop_scroll()
		else:
			start_scroll()
