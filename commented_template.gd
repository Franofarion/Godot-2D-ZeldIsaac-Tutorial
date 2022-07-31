# move this template to ~/Library/Application Support/Godot/script_templates
extends %BASE%


#### ACCESSORS ####
func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""


#### BUILT-IN ####
func _ready() -> void:
%TS%pass



### VIRTUALS ###




#### LOGIC ####




### INPUTS ###




#### SIGNAL RESPONSES ####
