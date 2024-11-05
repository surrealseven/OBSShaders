#include "FilterShader.h"
#include "ShaderCommon.h"




uniform float BitsPerChannel <
	string name = "BitsPerChannel";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 1;
	float maximum = 8;
> = 8;


float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(border_texture_sampler, v_in.uv);

	float scale = pow(2, BitsPerChannel - 1);

	color.rgb = floor(color.rgb * scale) / scale;

	return color;
}