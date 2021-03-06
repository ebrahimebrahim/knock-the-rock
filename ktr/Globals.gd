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
var extra_annotations : bool

func load_settings_config() -> Resource:
	
	# If no settings.tres, then return default settings
	if not ResourceLoader.exists("user://settings.tres"):
		return ResourceLoader.load("default_settings.tres")
		
	var settings_cfg = ResourceLoader.load("user://settings.tres","",true) # no_cache = true
	
	# If version mismatch in settings.tres, then also return default settings
	if not "version" in settings_cfg or settings_cfg.version != get_version_info()["version_number"]:
		return ResourceLoader.load("default_settings.tres")
	
	# If all good, return loaded settings.tres 
	return settings_cfg
