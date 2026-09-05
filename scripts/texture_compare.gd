class_name TextureCompare

static func _count_visible_pixels(t2: Texture2D) -> int:
    var count = 0

    for i in range(t2.get_width()):
        for j in range(t2.get_height()):
             if t2.get_image().get_pixel(i, j).a > 0:
                count += 1

    return count

static func compare(t1: RuntimeTexture, t2: Texture2D) -> float:
    if t1.get_width() != t2.get_width() or t1.get_height() != t2.get_height():
        return -1
    
    var total = _count_visible_pixels(t2)
    var same = 0

    for i in range(t1.get_width()):
        for j in range(t1.get_height()):
            if t1.get_pixel(i, j) == t2.get_image().get_pixel(i, j):
                same += 1

    return same / (total as float)