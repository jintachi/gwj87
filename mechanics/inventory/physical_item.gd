extends RigidBody2D
class_name PhysicalItem
signal picked_up

@export var item : InventoryItem
@export var tooltip : RichTextLabel
var tween : Tween

@onready var pickup: AudioStreamPlayer2D = $Pickup
@onready var place: AudioStreamPlayer2D = $Place

var on_moving_platform := false

func _ready() -> void:
	if place:
		place.play()

func pick_up(player: Player) -> void:
	if not player.general_inventory.try_add(item, player): return
	picked_up.emit()
	if pickup:
		remove_child(pickup)
		add_sibling(pickup)
		pickup.finished.connect(pickup.queue_free)
		pickup.play()
	queue_free()

func set_pickup_tooltip() -> void:
	tooltip.clear()
	tooltip.add_text("Press ")
	KeyIcons.add_tags(tooltip, KeyIcons.last_input_device("interact"))
	tooltip.add_text(" to pick up")

func set_inventory_full_tooltip() -> void:
	tooltip.clear()
	tooltip.add_text("Inventory Full!")

func item_in_range(player: Player) -> void:
	if tooltip:
		tooltip.visible = true
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(tooltip, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(tooltip, "scale", Vector2(1, 1), 0.4)
		if player.general_inventory.has_free_slot(item):
			KeyIconsInstance.last_device_changed.connect(set_pickup_tooltip)
			set_pickup_tooltip()
		else:
			set_inventory_full_tooltip()

func item_out_of_range(player: Player) -> void:
	KeyIconsInstance.last_device_changed.disconnect(set_pickup_tooltip)
	if tooltip:
		tooltip.visible = false
