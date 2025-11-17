shader_type canvas_item;
//stripes by alxl @ https://godotshaders.com/shader/animated-stripes/

uniform vec2 point1 = vec2(0.5,0.5);
uniform vec2 point2 = vec2(-0.5,-0.5);

uniform float amount = 64;
uniform float line_width = 0.008;
uniform float endpoint_size = 0.035;
uniform vec4 line_color : source_color;

uniform float divisions = 16.0; // increase for more stripe density
uniform float stripe_bias = 2.5; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 0.1;

//uniform float y_skew = 0.0;
//uniform float time_scale = 0.1;
//uniform vec2 aspect = vec2(288.0,162.0);
//uniform float aspect_factor = 2.0;

vec2 closest_line_point(vec2 coord){
	vec2 dir = point2 - point1;
	vec2 coord_dir = coord - point1;
	float t = dot(dir, coord_dir) / dot(dir, dir);
	if (t < 0.0){
		t = 0.0;
	}
	else if (t > 1.0){
		t = 1.0;
	}
	return point1 + dir * t;
}

void fragment() {

	vec2 centered_uv = UV * 2.0 - 1.0;
	vec2 grid_uv = floor(centered_uv * amount) / amount;

	if (length(closest_line_point(grid_uv) - grid_uv) < line_width){
		COLOR = line_color;
	}
	else{
		COLOR.a = 0.0;
	}

	float angle = atan(grid_uv.y, grid_uv.x);
	float w = cos(angle) * grid_uv.x + sin(angle) * grid_uv.y - speed * TIME;
	if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
		COLOR.a = 0.0;
	}

	if (grid_uv.x > max(point1.x, point2.x)){
		COLOR.a = 0.0;
	}
	if (grid_uv.x < min(point1.x, point2.x)){
		COLOR.a = 0.0;
	}
	if (grid_uv.y > max(point1.y, point2.y)){
		COLOR.a = 0.0;
	}
	if (grid_uv.y < min(point1.y, point2.y)){
		COLOR.a = 0.0;
	}
	if (length(grid_uv - point1) < endpoint_size){
		COLOR = line_color;
	}
	if (length(grid_uv - point2) < endpoint_size){
		COLOR = line_color;
	}
}