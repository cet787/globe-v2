shader_type spatial;

uniform float highlight_strength = 0.0;
uniform float select_highlight_strength = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (highlight_strength != 0.0) {
		ALBEDO = vec3(1.0, 0.0, 0.0);
		ALPHA = 1.0;
	} else if (select_highlight_strength != 0.0) {
		ALBEDO = vec3(0.0, 0.0, 1.0);
		ALPHA = 1.0;
	} else {
		ALBEDO = vec3(0.0, 0.0, 0.0);
		ALPHA = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
