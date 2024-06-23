#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float scale <
	string label = "Color scale";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;


sampler_state texture_sampler
{
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};

float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(texture_sampler, v_in.uv);
	color.rgb *= scale;
	return color;
}