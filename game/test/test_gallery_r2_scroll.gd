extends GutTest
## #640 — gallery R2 fling coast: lower friction than the engine ScrollContainer default
## so a release keeps scrolling (specs/ux/screens/gallery.md Experience intent).


func test_friction_is_below_engine_default() -> void:
	assert_lt(
		GalleryR2Scroll.FRICTION,
		1000.0,
		"#640: R2 friction stays below engine ScrollContainer's 1000 px/s²"
	)


func test_fling_coasts_after_release() -> void:
	var scroll := GalleryR2Scroll.new()
	scroll.size = Vector2(120, 200)
	var child := Control.new()
	child.custom_minimum_size = Vector2(120, 4000)
	scroll.add_child(child)
	add_child_autofree(scroll)
	await get_tree().process_frame
	scroll.scroll_vertical = 0
	scroll.fling(-900.0)
	var before := scroll.scroll_vertical
	for _i in 8:
		await get_tree().process_frame
	assert_gt(scroll.scroll_vertical, before, "#640: R2 keeps coasting after a fling")


func test_finger_delta_stops_coast() -> void:
	var scroll := GalleryR2Scroll.new()
	scroll.size = Vector2(120, 200)
	var child := Control.new()
	child.custom_minimum_size = Vector2(120, 4000)
	scroll.add_child(child)
	add_child_autofree(scroll)
	await get_tree().process_frame
	scroll.scroll_vertical = 100
	scroll.fling(-900.0)
	scroll.apply_finger_delta(12.0)
	assert_eq(scroll.is_processing(), false, "#640: a new drag cancels the coast")
	assert_eq(scroll.scroll_vertical, 88, "#640: finger delta still moves R2")
