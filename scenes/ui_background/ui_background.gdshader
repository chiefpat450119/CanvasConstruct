shader_type canvas_item;

uniform vec4 color = vec4(1, 1, 1, 1);

void fragment() {
	vec2 moving_uv = UV;
	moving_uv.x += TIME * 0.1;
	moving_uv.y += TIME * 0.05;
	float repeat_position = round(fract(moving_uv.x * 6.0 + moving_uv.y * 3.5 + 0.25));
	float brightness = mix(0.95, 1.0, repeat_position);
	COLOR = vec4((color * brightness).rgb, color.a);
}
