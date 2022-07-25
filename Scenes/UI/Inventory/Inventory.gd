extends Control
class_name Inventory

var item_list : Array = []

class ItemAmount:
	var amount : int = 0
	var item : ItemData = null

	func _init(_amount: int, _item: ItemData) -> void:
		amount = _amount
		item = _item


### BUILT-IN ###

func _ready() -> void:
	var __ = EVENTS.connect("object_collected", self, "_on_EVENTS_object_collected")



### LOGIC ###

func _append_item(item: ItemData, amount: int = 1) -> void:
	var item_amount_id = _find_item_id(item)

	if item_amount_id == -1:
		item_list.append(ItemAmount.new(amount, item))
	else :
		item_list[item_amount_id].amount += amount


func _remove_item(item: ItemData, amount: int = 1) -> void:
	var item_amount_id = _find_item_id(item)
	if item_amount_id == -1:
		push_error("%s could not be removed from the list. No itemAmout corresponding was found" % item.item_name)
	else :
		item_list[item_amount_id].amount -= amount
		if item_list[item_amount_id].amount <= 0:
			item_list.remove(item_amount_id)


# finds the position of the ItemAmount corresponding to the given item in the item_list
# and returns its index, if no ItemAmount corresponds to it returns -1
func _find_item_id(item: ItemData) -> int:
	for i in range(item_list.size()):
		var item_amount = item_list[i]
		if item_amount.item == item:
			return i
	return -1


func _print_inventory() -> void:
	print("--- INVENTORY CONTENT ---")
	print("")

	for item_amount in item_list:
		print(item_amount.item.item_name + ' : ' + String(item_amount.amount))

	print("")
	print("-------------------------")


### INPUTS ###

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		_print_inventory()

### SIGNAL RESPONSES ###
func _on_EVENTS_object_collected(item: Object) -> void:
	if item is Item:
		_append_item(item.item_data)

