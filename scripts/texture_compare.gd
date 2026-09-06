class_name TextureCompare

static func _count_visible_pixels(image: Image) -> int:
	var count := 0

	for i in range(image.get_width()):
		for j in range(image.get_height()):
			if image.get_pixel(i, j).a > 0:
				count += 1

	return count

static func compare(drawing: Image, reference: Texture2D) -> float:
	if (
		drawing.get_width() != reference.get_width()
		or drawing.get_height() != reference.get_height()
	):
		return -1

	var reference_image := reference.get_image()
	var total_pixel_count: int = (
		reference_image.get_width() * reference_image.get_height()
	)
	var required_pixel_count := _count_visible_pixels(reference_image)
	var empty_pixel_count := total_pixel_count - required_pixel_count
	var correctly_filled_pixel_count := 0
	var incorrectly_filled_pixel_count := 0

	for i in range(drawing.get_width()):
		for j in range(drawing.get_height()):
			var reference_pixel := reference_image.get_pixel(i, j)
			var drawing_pixel := drawing.get_pixel(i, j)
			if reference_pixel.a > 0:
				if drawing_pixel == reference_pixel:
					correctly_filled_pixel_count += 1
			elif drawing_pixel.a > 0:
				incorrectly_filled_pixel_count += 1

	var correct_percentage := 0.0
	if required_pixel_count > 0:
		correct_percentage = (
			float(correctly_filled_pixel_count) / required_pixel_count
		)

	var incorrect_percentage := 0.0
	if empty_pixel_count > 0:
		incorrect_percentage = (
			float(incorrectly_filled_pixel_count) / empty_pixel_count
		)

	return correct_percentage - incorrect_percentage / 2.0
