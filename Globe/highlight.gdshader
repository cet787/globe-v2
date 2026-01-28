shader_type spatial;

uniform bool highlighted = false;

void vertex() {
}
void fragment() {
	if (!highlighted) discard;
	
	ALBEDO = vec3(1.0, 0.0, 0.0);
	EMISSION = vec3(8.0, 0.0, 0.0);
	ALPHA = 0.9;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
