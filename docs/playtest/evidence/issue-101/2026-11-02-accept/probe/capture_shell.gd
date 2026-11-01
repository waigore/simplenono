extends SceneTree
## Temporary acceptance probe for #101 (not committed to the repo).


func _initialize() -> void:
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene"))
	print("run/main_scene=", main_scene)
	var packed := load(main_scene) as PackedScene
	var shell := packed.instantiate()
	root.add_child(shell)
	await process_frame
	await process_frame
	var label := shell.get_node("%PuzzleIdLabel") as Label
	print("puzzle id label=", label.text)
	print("visible=", label.is_visible_in_tree())
	var image := root.get_texture().get_image()
	var out := OS.get_environment("ACCEPT_101_SHOT")
	var err := image.save_png(out)
	print("screenshot=", out, " save=", err)
	quit(0)
