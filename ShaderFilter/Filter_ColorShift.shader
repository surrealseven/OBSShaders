#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Frequency <
	string name = "Frequency";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 2;
	float step = 0.01;
> = 1;


float4 mainImage(VertData v_in) : TARGET
{	
	float t = frac(elapsed_time * Frequency);

	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	float4 hsv = RgbaToHsva(color);
	hsv.x = frac(hsv.x + t);

	color = HsvaToRgba(hsv);

	return color;
}