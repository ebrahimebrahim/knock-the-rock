extends Node

func get_version_info():
	var commit_hash = "" # TODO: Read file containing commit hash. If it's not there, make it empty string.
	return {
		"version_number" : "0.0.0",
		"dev_or_release" : "release",
		"commit_hash" : commit_hash,
	}

var total_rocks_given : int
var corner_menu_hidden_by_default : bool

func load_settings_config() -> Resource:
	if not ResourceLoader.exists("user://settings.tres"):
		return ResourceLoader.load("default_settings.tres")
	return ResourceLoader.load("user://settings.tres","",true) # no_cache = true
