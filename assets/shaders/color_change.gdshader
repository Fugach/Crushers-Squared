shader_type canvas_item;

uniform float red = 1.0;
uniform float green = 1.0;
uniform float blue = 1.0;
uniform float alpha = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	COLOR = vec4(red, green, blue, alpha);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
