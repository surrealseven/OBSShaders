#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Frequency <
	string label = "Frequency";
> = 1;

uniform float Minimum <
	string label = "Minimum";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0;

uniform float Maximum <
	string label = "Maximum";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 1;

uniform float DutyCycle <
	string label = "Duty Cycle";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.5;

uniform float Smoothing <
	string label = "Smoothing";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0;


float4 mainImage(VertData v_in) : TARGET
{	
	float t = frac(elapsed_time * Frequency);

	float half = DutyCycle * 0.5;
	float on = 0.5 - half;
	float off = 0.5 + half;
	float d = min(min(Smoothing * 0.25, half), 1.0 - half);
	t = smoothstep(on - d, on + d, t) * (1 - smoothstep(off - d, off + d, t));

	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);
	color.a *= lerp(Minimum, Maximum, t);

	return color;
}