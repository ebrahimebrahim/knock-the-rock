extends Node

func get_version_info():
	var commit_hash = ""
	var file = File.new()
	var err = file.open("res://commit_hash.txt", File.READ)
	if err == OK :
		commit_hash = file.get_as_text().strip_edges()
	file.close()

	var version_number = "[version number error]"
	err = file.open("res://version_number.txt", File.READ)
	if err == OK :
		version_number = file.get_as_text().strip_edges()
	file.close()


	
	return {
		"version_number" : version_number,
		"dev_or_release" : "dev",	 # Edit here for release!
		"commit_hash" : commit_hash,
	}

var total_rocks_given : int
var corner_menu_hidden_by_default : bool

func load_settings_config() -> Resource:
	if not ResourceLoader.exists("user://settings.tres"):
		return ResourceLoader.load("default_settings.tres")
	return ResourceLoader.load("user://settings.tres","",true) # no_cache = true
