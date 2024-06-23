#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float XScale <
	string name = "Horizontal Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 0;

uniform float YScale <
	string name = "Vertical Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 0;


float GetRandom(float2 p)
{
	float2 r = float2(
		23.14069263277926, // e^pi (Gelfond's constant)
		2.665144142690225 // 2^sqrt(2) (Gelfond–Schneider constant)
	);
	return frac(cos(dot(p, r)) * 12345.6789);
}

float4 mainImage(VertData v_in) : TARGET
{	
	float rx = GetRandom(4 * (rand_f + v_in.uv));
	float ry = GetRandom(4 * (rand_f + v_in.uv));

	float2 offset = (float2(rx, ry) * 2 - 1) * float2(XScale, YScale);
	
	float2 uv = frac(v_in.uv + offset * uv_pixel_interval);

	float4 color = image.Sample(clamp_texture_sampler, uv);

	return color;
}