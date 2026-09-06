class_name DamagableComponent
extends Node

const DAMAGE_FRAGMENT_SCENE := preload("res://scenes/damage_fragment/damage_fragment.tscn")

const _NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

@export var visuals: RuntimeTexture

# dmg should be a percentage (0 - 1) of the texture area.
func damage(dmg: float) -> int:
	if visuals == null:
		return 0

	var remove_pixels := roundi(clampf(dmg, 0.0, 1.0) * visuals.get_width() * visuals.get_height())
	return damage_pixels(remove_pixels)


func damage_pixels(pixel_count: int) -> int:
	if visuals == null or visuals.visible_pixels.is_empty() or pixel_count <= 0:
		return 0

	var edge_indices := _get_edge_indices(visuals.visible_pixels)
	if edge_indices.is_empty():
		return 0

	var selected_pixels := _select_indices(
		visuals.visible_pixels, edge_indices.pick_random(), pixel_count
	)
	_spawn_damage_fragment(selected_pixels)
	visuals.set_pixels(selected_pixels, Color.TRANSPARENT)
	return selected_pixels.size()


func can_receive_damage() -> bool:
	return visuals != null and not visuals.visible_pixels.is_empty()


func _spawn_damage_fragment(pixels: Array[Vector2i]) -> void:
	if pixels.is_empty() or not is_inside_tree() or visuals.sprite2d == null:
		return

	var fragment_parent := get_tree().current_scene
	if fragment_parent == null:
		return

	var minimum := pixels[0]
	var maximum := pixels[0]
	for pixel in pixels:
		minimum.x = mini(minimum.x, pixel.x)
		minimum.y = mini(minimum.y, pixel.y)
		maximum.x = maxi(maximum.x, pixel.x)
		maximum.y = maxi(maximum.y, pixel.y)

	var fragment_size := maximum - minimum + Vector2i.ONE
	var fragment_image := Image.create(
		fragment_size.x, fragment_size.y, false, Image.FORMAT_RGBA8
	)
	fragment_image.fill(Color.TRANSPARENT)
	var source_image := visuals.get_image()
	for pixel in pixels:
		fragment_image.set_pixelv(pixel - minimum, source_image.get_pixelv(pixel))

	var fragment := DAMAGE_FRAGMENT_SCENE.instantiate() as DamageFragment
	fragment_parent.add_child(fragment)

	# A Sprite2D's rectangle starts at the source texture's local top-left. Moving
	# to the cropped region's center makes the fragment overlap the pixels exactly
	# before physics-like movement begins on the following frame.
	var local_center := (
		visuals.sprite2d.get_rect().position
		+ Vector2(minimum)
		+ Vector2(fragment_size) * 0.5
	)
	fragment.global_transform = (
		visuals.sprite2d.global_transform * Transform2D(0.0, local_center)
	)
	fragment.initialize(
		ImageTexture.create_from_image(fragment_image),
		_get_outward_direction(local_center.x)
	)


func _get_outward_direction(local_x: float) -> float:
	if not is_zero_approx(local_x):
		return signf(local_x)
	return -1.0 if randf() < 0.5 else 1.0


func _get_edge_indices(pixels: Array[Vector2i]) -> Array[int]:
	var edge_indices: Array[int] = []
	var available: Dictionary = {}
	for pixel in pixels:
		available[pixel] = true

	for index in pixels.size():
		var pixel := pixels[index]
		for offset in _NEIGHBOR_OFFSETS:
			if not available.has(pixel + offset):
				edge_indices.append(index)
				break

	return edge_indices


func _select_indices(pixels: Array[Vector2i], start: int, amount: int) -> Array[Vector2i]:
	var selected: Array[Vector2i] = []
	if pixels.is_empty() or amount <= 0:
		return selected

	# A dictionary provides constant-time neighbor checks and prevents a pixel from
	# being selected more than once if the source array contains duplicates.
	var available: Dictionary = {}
	for pixel in pixels:
		available[pixel] = true

	var target_amount := mini(amount, available.size())
	var start_pos := pixels[clampi(start, 0, pixels.size() - 1)]
	var frontier: Array[Vector2i] = [start_pos]
	var visited: Dictionary = {}
	visited[start_pos] = true

	while selected.size() < target_amount:
		# Damage may have divided the remaining pixels into separate components. If
		# this component is exhausted, continue from the closest remaining pixel.
		if frontier.is_empty():
			var closest_pixel := Vector2i.ZERO
			var closest_distance := 0
			var found_pixel := false

			for pixel in pixels:
				if visited.has(pixel):
					continue

				var distance := start_pos.distance_squared_to(pixel)
				if not found_pixel or distance < closest_distance:
					closest_pixel = pixel
					closest_distance = distance
					found_pixel = true

			if not found_pixel:
				break

			visited[closest_pixel] = true
			frontier.append(closest_pixel)

		# Growing from a random edge pixel avoids the uniform distance rings that
		# produce a diamond-shaped chunk while keeping the damage connected.
		var random_frontier_index := randi_range(0, frontier.size() - 1)
		var current_pixel := frontier[random_frontier_index]
		frontier[random_frontier_index] = frontier.back()
		frontier.pop_back()
		selected.append(current_pixel)

		for offset in _NEIGHBOR_OFFSETS:
			var neighbor := current_pixel + offset
			if available.has(neighbor) and not visited.has(neighbor):
				visited[neighbor] = true
				frontier.append(neighbor)

	return selected
