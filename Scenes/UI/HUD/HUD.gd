extends TextureRect

onready var coin_counter_label = $CoinCounter

func _ready() -> void:
	var __ = EVENTS.connect("nb_coins_changed", self, "_on_EVENTS_nb_coins_changed")
	__ = EVENTS.connect("character_hp_changed", self, "_on_EVENTS_character_hp_changed")
	__ = EVENTS.connect("character_mp_changed", self, "_on_EVENTS_character_mp_changed")

func _on_EVENTS_nb_coins_changed(nb_coins) -> void:
	coin_counter_label.set_text(String(nb_coins))

func _on_EVENTS_character_hp_changed(hp: int) -> void:
	$HP_BAR.set_value(hp)

func _on_EVENTS_character_mp_changed(mp: int) -> void:
	$MP_BAR.set_value(mp)
