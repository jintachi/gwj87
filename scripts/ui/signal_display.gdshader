shader_type canvas_item;


uniform float subdivisions = 32.0;
uniform float radius = 1.0;
uniform float band_mod = 0.1;
uniform float signal_strength = 1.0;

void fragment() {
	
	vec2 pixel_uv = vec2(round(UV.x * subdivisions) / subdivisions, round(UV.y * subdivisions) / subdivisions);
	vec2 uv = pixel_uv * 2.0 - 1.0;

	float uv_length = length(uv);
	float uv_angle = atan(uv.y, uv.x);
	COLOR.a = 0.0;
	if (uv_length < radius * signal_strength){
		COLOR = vec4(0.0, 1.0, 0.2, 1.0);
	}
	if (mod(uv_length, band_mod) < 0.1){
		COLOR.a = 0.0;
	}
	if (abs(-uv_angle - PI * 0.5) > PI * 0.35){
		COLOR.a = 0.0;
	}
	if (uv_length < 0.09){
		COLOR = vec4(0.0, 1.0, 0.2, 1.0);
	}
}
