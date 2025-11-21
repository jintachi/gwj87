shader_type canvas_item;

uniform sampler2D tex : repeat_enable;
uniform vec2 scroll_vector = vec2(0.8, 0.2);
uniform float subdivisions = 32.0;
uniform float speed = 20.0;
uniform vec2 tex_size = vec2(128.0, 128.0);

varying vec2 world_pos;
varying vec4 color;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	color = COLOR;
}

void fragment() {
	vec2 uv = world_pos / tex_size;
	vec2 pixel_uv = vec2(round(uv.x * subdivisions) / subdivisions, round(uv.y * subdivisions) / subdivisions);
//
	float discrete_time = (floor(TIME * speed) / speed);
	COLOR = color * texture(TEXTURE, vec2(pixel_uv.x + discrete_time * scroll_vector.x, pixel_uv.y - discrete_time * scroll_vector.y));
}
