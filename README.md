# Knock the Rock

To build in linux download Godot and set the environment variable `GODOT` to point to your Godot executable.

```export GODOT=<path to your Godot application>```

Then run the script `make.sh` in the repository.

Version string is done in `ktr/version_number.txt` and dev/release state is set in `ktr/Globals.gd`

---

Here is the process for adding a setting to the game:
- add widget for it in `Settings.tscn`
- add exported variable in `SettingsConfig.gd`
- set a default value for it in the resource `default_settings.tres`
- update the methods `panel_knobs_to_resource` and `resource_to_panel_knobs` in `Settings.gd`
- add tooltip and label strings to `Strings.gd` and then update `setup_ui_labels` in `Settings.gd`
- finally, do stuff with the setting via `Globals.load_settings_config()`, or via `$Overlays/Settings.settings_config` if working from `MenuScreen.tscn`
