shader_type canvas_item;

uniform sampler2D pic;
uniform float pic_scale = 2.0;
uniform float pic_rot = 0.0;
uniform vec2 origin = vec2(0.0);
uniform float subdivisions = 32.0;
uniform bool round_alpha = false;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}
//A couple goals here for the forseeable future.
//see interactions between tweening modulate of parents and shader on current node

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || (texture(texture, xy).a <= 0.0 || texture(texture, xy) == color)) == inside) {
				return true;
			}
		}
	}

	return false;
}


vec2 rotateUV(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
			vec2(cos(angle), sin(angle)));

    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;

    return uv;
}

void fragment() {
	COLOR.a = 0.0;
	vec2 pixel_uv = vec2(round(UV.x * subdivisions) / subdivisions, round(UV.y * subdivisions) / subdivisions);
	vec2 shrink_uv = rotateUV(pixel_uv + vec2(-origin.x, origin.y), vec2(0.5), pic_rot) * pic_scale - vec2((pic_scale - 1.0) * 0.5);
	COLOR = texture(pic, shrink_uv);
	if (round_alpha){
		COLOR.a = round(COLOR.a);
	}

	vec2 uv = shrink_uv;

	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
		COLOR.a += (1.0 - COLOR.a) * color.a;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}