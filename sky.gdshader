shader_type sky;

uniform float star_density = 250.0;
uniform float star_threshold = 0.985;
uniform float star_min_size = 0.05;
uniform float star_max_size = 0.1;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5435);
}

void sky() {
	
	float y = SKY_COORDS.y * 2.0 - 1.0; // -1 to 1
	float gradient = exp(-y * y * 40.0);
	COLOR = vec3(gradient * 0.19, gradient * 0.18, gradient * 0.28);
	
	// Sky UV in [0,1]
	vec2 uv = SKY_COORDS.xy;
	
	//Grid setup
	vec2 grid_uv = uv * star_density;
	vec2 cell = floor(grid_uv);
	vec2 local = fract(grid_uv) - 0.5;
	
	// Random per-cell values
	float h = hash(cell);
	
	if (h > star_threshold) {
		float size = mix(star_min_size, star_max_size, hash(cell + 1.3));
		float brightness = mix(0.6, 1.2, hash(cell + 2.1));
		
		float dist = length(local);
		float star = smoothstep(size, 0.0, dist);
		
		COLOR += vec3(star * brightness);
	}
}
