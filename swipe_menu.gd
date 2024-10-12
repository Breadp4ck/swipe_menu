extends ScrollContainer
class_name SwipeMenu


@export var card_scenes: Array[PackedScene]
@export_range(0.0, 2.0, 0.001, "or_greater") var tween_time := 0.5
@export_range(0, 100, 1, "or_greater", "suffix:px") var separation := 20
@export_range(0, 1, 0.001, "or_less", "or_greater") var first_offset := 0.3
@export var transition: Tween.TransitionType = Tween.TRANS_BACK
@export var ease: Tween.EaseType = Tween.EASE_OUT

signal card_selected(card: Control, card_idx: int)

@onready var center_container: CenterContainer = $CenterContainer
@onready var card_container: HBoxContainer = $CenterContainer/MarginContainer/CardContainer
@onready var margin_container: MarginContainer = $CenterContainer/MarginContainer


var current_card := 0
var cards: Array[Control] = []
var card_centers: Array[float] = []

var scroller: Tween


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	
	scroller = get_tree().create_tween()
	
	var viewport_width: float = get_viewport_rect().size.x
	margin_container.set("theme_override_constants/margin_left", viewport_width)
	margin_container.set("theme_override_constants/margin_right", viewport_width)
	card_container.set("theme_override_constants/separation", separation)
	
	for card_scene in card_scenes:
		var card: Control = card_scene.instantiate()
		cards.push_back(card)
		card_container.add_child(card)
	
	# Wait control nodes to setup
	await get_tree().process_frame
	
	var offset := viewport_width - first_offset * viewport_width
	for i in range(cards.size()):
		var card := cards[i]
		var center := offset + 0.5 * card.size.x
		
		card_centers.push_back(center)
		offset += card.size.x + separation
	
	jump_to(current_card)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		current_card = clampi(current_card - 1, 0, current_card)
		jump_to(current_card)
	
	elif event.is_action_pressed("ui_right"):
		var cards_total := card_container.get_children().size()
		current_card = clampi(current_card + 1, 0, cards_total - 1)
		jump_to(current_card)


## Jump to the card by its position in sequence.
func jump_to(idx: int) -> void:
	scroller.kill()
	var scroll_target := card_centers[idx]
	card_selected.emit(cards[idx], idx)
	
	scroller = get_tree().create_tween()
	scroller\
		.tween_property(self, "scroll_horizontal", scroll_target, tween_time)\
		.from(scroll_horizontal)\
		.set_trans(transition)\
		.set_ease(ease)


## Stop all moving and tweening.
func stop() -> void:
	scroller.kill()


## Get nearest card index based on current container state.
func get_nearest_card() -> int:
	var min_distance := 1e12
	var nearest_card := 0
	
	for i in range(card_centers.size()):
		var center := card_centers[i]
		var cur_distance := absf(scroll_horizontal - center)
		
		if cur_distance < min_distance:
			min_distance = cur_distance
			nearest_card = i
	
	return nearest_card


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			stop()
		else:
			current_card = get_nearest_card()
			jump_to(current_card)
