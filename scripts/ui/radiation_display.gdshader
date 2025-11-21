shader_type canvas_item;

uniform float subdivisions = 32.0;
uniform sampler2D noise : repeat_enable;
uniform float noise_strength = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {


	vec2 pixel_uv = vec2(round(UV.x * subdivisions) / subdivisions, round(UV.y * subdivisions) / subdivisions);
	if (abs(0.5 - pixel_uv.y) < texture(noise, vec2(pixel_uv.x + TIME * 50.0, 0.5)).r * noise_strength ){
		COLOR = vec4(0.0, 1.0, 0.2, 1.0);
	}

}
