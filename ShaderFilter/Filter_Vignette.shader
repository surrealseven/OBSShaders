#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float InnerRadius <
	string name = "Inner Radius";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.1;

uniform float OuterRadius <
	string name = "Outer Radius";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 5.0;
	float step = 0.01;
> = 0.9;

uniform bool Circular <
	string name = "Circular";	
> = false;

uniform float4 VignetteColor<
	string name = "Color";
> = { 0.0, 0.0, 0.0, 1.0 };



float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	float2 center = float2(0, 0);
	float2 pos = v_in.uv - 0.5;

	if (Circular)
		pos.x *= uv_size.x / uv_size.y;

	float dist = distance(pos, center);

	float t = smoothstep(InnerRadius, OuterRadius, dist);

	color = lerp(color, VignetteColor, t);

	return color;
}