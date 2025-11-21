extends RigidBody2D
class_name PhysicalItem
signal picked_up

@export var item : InventoryItem
@export var tooltip : Label
var tween : Tween

func pick_up(player: Player) -> void:
	if not player.general_inventory.try_add(item, player): return
	picked_up.emit()
	queue_free()

func item_in_range(player: Player) -> void:
	if tooltip:
		tooltip.visible = true
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(tooltip, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(tooltip, "scale", Vector2(1, 1), 0.4)
		if player.general_inventory.has_free_slot(item):
			tooltip.text = "Press E to pick up"
		else:
			tooltip.text = "Inventory full"
	
func item_out_of_range(player: Player) -> void:
	if tooltip:
		tooltip.visible = false
