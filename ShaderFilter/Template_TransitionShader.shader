#include "TransitionShader.h"


// examples

uniform string notes < 
	string label = "*";
	string widget_type = "info";
> = "This is some example text.";

uniform float4 multiplier_color <
	string widget_type = "slider";
	string group = "Color Group";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = { 1, 1, 1, 1 };

// uniform int select_test <
//   string label = "Int Select";
//   string widget_type = "select";
//   int    option_0_value = 0;
//   string option_0_label = "First";
//   int    option_1_value = 1;
//   string option_1_label = "Second";
//   int    option_2_value = 3;
//   string option_2_label = "Third";
// > = 3;

// main texture sampler

sampler_state texture_sampler
{
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};



float4 mainImage(VertData v_in) : TARGET
{
	float2 aUv = v_in.uv;
	float2 bUv = v_in.uv;

	aUv.x += transition_time;

	float4 aVal = image_a.Sample(texture_sampler, aUv);
	float4 bVal = image_b.Sample(texture_sampler, bUv);

	float4 rgba = lerp(aVal, bVal, transition_time) * multiplier_color;


	if (convert_linear)
		rgba.rgb = srgb_nonlinear_to_linear(rgba.rgb);
	return rgba;
}