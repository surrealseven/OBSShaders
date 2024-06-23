// stuff defined for us in the transition shader

// source image
uniform texture2d image_a <
	string label = "Image A";
>;

// destination image
uniform texture2d image_b <
	string label = "Image B";
>;

// true if we need to convert from srgb to linear
uniform bool convert_linear = false;

// transition time from 0 to 1
uniform float transition_time <
	string label = "Transiton Time";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.5;

// time in seconds since the filter was created
// uniform float elapsed_time;

// random float represneting the local time
// uniform float local_time;

// count of how many times the shader has rendered a page
// uniform int loops;

// per frame random number between 0 and 1
// uniform float rand_f;

// per activation, load, or change of settings random number between 0 and 1
// uniform float rand_activation_f;

// per instance on load random number between 0 and 1
// uniform float rand_instance_f;



