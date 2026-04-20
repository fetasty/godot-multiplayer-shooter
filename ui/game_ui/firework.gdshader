shader_type canvas_item;
// 开启 Add (相加) 混合模式，非常适合烟花这种发光特效
//render_mode blend_add;
// 改为预乘 Alpha 模式, 在完全不透明的地方（中心点）覆盖背景，在半透明的地方（光晕边缘）融入背景
render_mode blend_premul_alpha;

uniform vec2 resolution = vec2(620.0, 360.0);
uniform float firework_count: hint_range(1.0, 50.0, 1.0) = 5.0;
uniform float particle_count: hint_range(1.0, 50.0, 1.0) = 25.0;
uniform float size: hint_range(1.0, 10.0, 0.1) = 1.0;
uniform float sharpen: hint_range(1.0, 10.0, 0.1) = 1.5;
uniform float speed: hint_range(1.0, 10.0, 0.1) = 2.0;
uniform float gravity: hint_range(0.1, 2.0, 0.1) = 0.9;
uniform float lifetime: hint_range(1.0, 10.0, 0.1) = 7.0;

vec2 noise(vec2 uv) {
	uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
	return fract(sin(uv) * 43758.5453123) * 0.5;
}

vec3 spark(vec2 uv, vec2 position, float index, float cycle) {
	vec2 direction = noise(vec2(0.1, 0.3) * index);
	if (mod(index, 2.0) == 0.0) {
		direction.x = -direction.x;
	}
	direction.y -= cycle * gravity * 0.1;
	float shape = 1.0 / length(uv + position + direction * cycle) * size * 0.01;
	float red = shape * noise(vec2(0.1, 0.2) * index).x;
	float green = shape * noise(vec2(0.3, 0.4) * index).x;
	float blue = shape * noise(vec2(0.5, 0.6) * index).x;
	return pow(vec3(red, green, blue), vec3(sharpen));
}

vec3 firework(vec2 uv, float index) {
	vec3 color = vec3(0.0);
	vec2 position = noise(vec2(0.2, 0.4) * index);
	if (mod(index, 2.0) == 0.0) {
		position.x = -position.x;
	}
	float cycle = mod(TIME * speed, lifetime * (1.0 + noise(vec2(0.1, 0.9) * index).x));
	for (float i = 1.0; i <= particle_count; i += 1.0) {
		color += spark(uv, position, i, cycle);
	}
	return color;
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	vec3 color = vec3(0.0);
	for (float i = 0.0; i < firework_count; i += 1.0) {
		color += firework(uv, i);
	}
	// [修改2] 计算 Alpha 通道：取 RGB 中最亮的一个通道作为透明度
	float alpha = max(max(color.r, color.g), color.b);
	// 限制 alpha 最大值为 1.0，防止由于多次叠加导致 alpha 溢出产生渲染异常
	alpha = clamp(alpha, 0.0, 1.0);
	
	COLOR = vec4(color, alpha);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
