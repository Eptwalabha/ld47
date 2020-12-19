shader_type spatial;
render_mode unshaded;
render_mode world_vertex_coords;

uniform vec3 rand_dot = vec3(12.37491, 25.49193, 60.49193);
uniform float angle = 0.;
uniform float s = 40.;
uniform vec4 color_1 : hint_color;
uniform vec4 color_2 : hint_color;

varying vec3 ro;
varying vec3 v;
varying mat2 r;

const float PI = 3.14159;

void vertex() {
	ro = (inverse(WORLD_MATRIX) * CAMERA_MATRIX[3]).xyz;
	v = (inverse(WORLD_MATRIX) * vec4(VERTEX, 1.)).xyz;
	r = mat2(
			vec2(cos(angle), sin(angle)),
			vec2(-sin(angle), cos(angle))
		);
}

float rand21(vec2 p) {
	return fract(sin(dot(p, rand_dot.xz)) * 19894.28934);
}

vec3 toPolar(vec3 p) {
	float l = length(p);
	float ph = atan(p.z / p.x);
	float rho = acos(p.y / l);
	return vec3(l, ph, rho);
}

float stars(vec3 p, float size) {
	vec2 pol = toPolar(p).yz * size;
	vec2 id = floor(pol);
	float d = smoothstep(0.97, .99, rand21(id));
	if (d > 0.) {
		vec2 uv = fract(pol) - .5;
		float l = 1. - (length(uv) * 7.);
		return max(l * d, 0.);
	}
	return 0.;
}

void fragment() {
	vec3 p = normalize(v - ro);
	p.xz *= r;
	float h = max(p.y, 0.0);
	vec3 col = vec3(0.);
	
	if (h > 0.) {
		// background gradient
		float h2 = smoothstep(-.35, .25, h);
		col = mix(color_1, color_2, h2).xyz;
		
		// fade star's visibility at horizon
		vec3 star = vec3(stars(p, s));
		col += star * pow(smoothstep(0, .5, h), 3.);
	}
	
	ALBEDO = col;
}