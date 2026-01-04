shader_type spatial;

uniform bool highlighted = false;

void vertex() {
}

void fragment() {
	if (highlighted) {
		EMISSION = vec3(5.0, 0.0, 0.0);
		ALBEDO = vec3(1.0, 0.0, 0.0);
	} else {
		EMISSION = vec3(0.0, 0.0, 0.0);
		ALBEDO = vec3(1.0, 1.0, 1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
