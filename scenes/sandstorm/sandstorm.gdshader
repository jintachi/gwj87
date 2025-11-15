shader_type canvas_item;

uniform vec2 scroll_vector = vec2(0.8, 0.2);
uniform float subdivisions = 32.0;

void fragment() {

	vec2 uv = UV * 2.0 - 1.0;
	vec2 pixel_uv = vec2(round(uv.x * subdivisions) / subdivisions, round(uv.y * subdivisions) / subdivisions);

	float discrete_time = floor(TIME * 20.0) * 0.1;
	COLOR = texture(TEXTURE, vec2(uv.x + discrete_time * scroll_vector.x, uv.y - discrete_time * scroll_vector.y));
	if (COLOR.a > 0.0){
		COLOR = vec4(0.2,0.0,0.1,1.0);
	}
}
