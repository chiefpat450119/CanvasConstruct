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
	var total := _count_visible_pixels(reference_image)
	if total == 0:
		return 0.0

	var same := 0

	for i in range(drawing.get_width()):
		for j in range(drawing.get_height()):
			var reference_pixel := reference_image.get_pixel(i, j)
			if (
				reference_pixel.a > 0
				and drawing.get_pixel(i, j) == reference_pixel
			):
				same += 1

	return same / float(total)
