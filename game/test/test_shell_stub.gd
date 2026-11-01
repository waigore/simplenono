extends GutTest
## Shell stub screen — [b]CMP-shell[/b] stub, [b]components/shell.md[/b].
##
## Asserts only what the stub promises: the main scene is the shell stub, and the
## stub holds and displays a hardcoded puzzle id. Nothing here expects attempt or
## pack access, navigation, or a puzzle target scene (#112, #110).

const SHELL_SCENE := "res://presentation/shell.tscn"
const PROJECT_FILE := "res://project.godot"


func test_main_scene_is_the_shell_stub():
	var project := ConfigFile.new()
	assert_eq(project.load(PROJECT_FILE), OK, "project.godot loads")
	assert_eq(
		project.get_value("application", "run/main_scene"),
		SHELL_SCENE,
		"the shell stub is the run entry",
	)
	assert_false(
		ResourceLoader.exists("res://main.tscn"),
		"the previous bare run entry is gone",
	)


func test_shell_stub_displays_the_hardcoded_puzzle_id():
	assert_true(ResourceLoader.exists(SHELL_SCENE), "shell stub scene exists")
	var scene := load(SHELL_SCENE) as PackedScene
	var shell: Shell = scene.instantiate() as Shell
	assert_not_null(shell, "shell stub roots on Shell")
	add_child_autofree(shell)
	assert_eq(shell.STUB_PUZZLE_ID, "pack-000", "stub holds a hardcoded puzzle id")
	var label := shell.get_node("%PuzzleIdLabel") as Label
	assert_not_null(label, "stub shows the puzzle id")
	assert_eq(label.text, shell.STUB_PUZZLE_ID, "shown id is the constant")
