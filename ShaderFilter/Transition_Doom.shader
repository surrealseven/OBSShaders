#include "ShaderCommon.h"
#include "TransitionShader.h"



uniform int strip_count <
	string label = "Strip Count";
	string widget_type = "slider";
	int minimum = 1;
	int maximum = 2048;
> = 160;

uniform float frequency <
	string label = "Frequency";
	string widget_type = "slider";	
	float minimum = 0.1;
	float maximum = 3.0;
	float step = 0.1;
> = 0.75;

uniform float amplitude <
	string label = "Amplitude";
	string widget_type = "slider";	
	float minimum = 0.0;
	float maximum = 3.0;
	float step = 0.01;
> = 1.3;



float4 mainImage(VertData v_in) : TARGET
{
	float2 uv = v_in.uv;

	float quant = trunc(uv.x * strip_count) / strip_count;	

	float r = rand_instance_f;

	float offset =
		sin(PI * 2 * (quant * (frequency * 4) + r)) *
		cos(PI * 2 * (quant * (frequency * 5) + r)) *
		sin(PI * 2 * (quant * (frequency * 6) + r)) *
		cos(PI * 2 * (quant * (frequency * 7) + r));
	

	offset = offset * amplitude + (transition_time * (amplitude * 2 + 1) - amplitude);
	offset = max(offset, 0);

	uv.y -= offset;

	float4 bgColor = image_b.Sample(border_texture_sampler, v_in.uv);
	float4 color = image_a.Sample(border_texture_sampler, uv);

	if (uv.y < 0)
		color = bgColor;

	if (convert_linear)
		color.rgb = srgb_nonlinear_to_linear(color.rgb);
	return color;
}