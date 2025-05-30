var config := ConfigFile.new()
var config_path := "user://settings.cfg"

func load_config():
	var err = config.load(config_path)
	if err != OK:
		print("⚠️ No settings file found. Using defaults.")
		config.save(config_path)

func save_config():
	config.save(config_path)

func get_setting(section: String, key: String, default):
	return config.get_value(section, key, default)

func set_setting(section: String, key: String, value):
	config.set_value(section, key, value)
