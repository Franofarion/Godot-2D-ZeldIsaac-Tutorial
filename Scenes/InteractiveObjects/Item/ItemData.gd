extends Resource
class_name ItemData

export(Constants.DAMAGE_TYPE) var damage_type : int = Constants.DAMAGE_TYPE.HP
export var damage : int = 0

export var item_name : String = ""
export var description : String = ""

export var price : int = -1

export var world_texture : Texture = null
export var inventory_texture : Texture = null
