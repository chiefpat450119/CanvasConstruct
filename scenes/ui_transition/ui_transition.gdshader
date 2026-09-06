shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float diagonal_position = (UV.x + (1.0 - UV.y)) * 0.5;
	float visibility = 0.0;

	if (progress > 0.0 && progress <= 0.5) {
		float fill_edge = progress * 2.0;
		visibility = step(diagonal_position, fill_edge);
	} else if (progress > 0.5 && progress < 1.0) {
		float clear_edge = (progress - 0.5) * 2.0;
		visibility = step(clear_edge, diagonal_position);
	}

	COLOR.a *= visibility;
}
