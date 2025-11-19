shader_type canvas_item;

uniform sampler2D tex : repeat_enable;
uniform float tiling = 1;
uniform float ratio = 1.0;
uniform float subdivisions = 32.0;
uniform vec2 tex_size = vec2(128.0, 128.0);
uniform vec2 offset = vec2(1.0, 1.0);
uniform vec4 color_shift : source_color = vec4(1.0);
uniform float color_weight = 0.0;

varying vec2 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_pos.y *= ratio;
}

void fragment() {
	if (COLOR.a > 0.1 && (COLOR.r > 0.99 && COLOR.g > 0.99 && COLOR.b > 0.99)){	
		vec2 tex_uv = vec2(tiling, tiling) / tex_size;
		vec2 new_uv = world_pos * tex_uv + offset / 10.0;
		vec2 pixel_uv = vec2(round(new_uv.x * subdivisions) / subdivisions, round(new_uv.y * subdivisions) / subdivisions);
		COLOR = texture(tex, pixel_uv);
		COLOR.a = round(COLOR.a);
		COLOR.rgb -= vec3(0.05);
	}
	if (COLOR.a > 0.1){
		COLOR.rgb = mix(COLOR.rgb, color_shift.rgb, color_weight);
	}
}