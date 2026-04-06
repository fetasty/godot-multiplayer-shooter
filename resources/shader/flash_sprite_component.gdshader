shader_type canvas_item;

uniform float percent: hint_range(0.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 flash_color = vec4(1.0, 1.0, 1.0, color.a);
	COLOR = mix(color, flash_color, percent);
}

