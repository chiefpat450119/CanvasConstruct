shader_type canvas_item;

void fragment() {
	vec2 moving_uv = UV;
	moving_uv.x += TIME * 0.1;
	moving_uv.y += TIME * 0.05;
	float repeat_position = round(fract(moving_uv.x * 6.0 + moving_uv.y * 3.5 + 0.25));
	float brightness = mix(0.95, 1.0, repeat_position);
	COLOR = vec4(vec3(brightness), 1.0);

}
