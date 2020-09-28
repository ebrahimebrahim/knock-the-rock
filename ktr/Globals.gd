extends Node

const version = "0.0.0dev"

var total_rocks_given : int
var corner_menu_hidden_by_default : bool

func load_settings_config() -> Resource:
	if not ResourceLoader.exists("user://settings.tres"):
		return ResourceLoader.load("default_settings.tres")
	return ResourceLoader.load("user://settings.tres","",true) # no_cache = true
