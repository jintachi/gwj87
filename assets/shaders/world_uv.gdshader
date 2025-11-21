shader_type canvas_item;

uniform sampler2D tex : repeat_enable;
uniform vec2 tex_size = vec2(128.0, 128.0);

varying vec2 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 new_uv = world_pos / tex_size;
	COLOR.rgb = texture(tex, new_uv).rgb;
}