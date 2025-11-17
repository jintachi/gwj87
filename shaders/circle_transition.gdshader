shader_type canvas_item;

uniform lowp vec3 color : source_color;
uniform float radius : hint_range(0, 1) = 1.0;

varying vec2 size;

void vertex() {
	size = mat2(inverse(MODEL_MATRIX) * inverse(CANVAS_MATRIX) * inverse(SCREEN_MATRIX)) * vec2(1, 1);
}

vec2 step_px(vec2 uv, float px_size) {
	return floor(uv * px_size) / px_size;
}

void fragment() {
	vec2 aspect_ratio = (size / max(size.x, size.y));
	vec2 v = (step_px(UV, 256) - 0.5) * aspect_ratio;
	float inside = length(v) >= (radius * length(aspect_ratio) * 0.5) ? 1.0 : 0.0;
	COLOR = vec4(color, inside);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
