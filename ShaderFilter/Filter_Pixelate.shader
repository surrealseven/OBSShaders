#include "FilterShader.h"
#include "ShaderCommon.h"

uniform int CellSize <
	string name = "Cell Size";
	string widget_type = "slider";
	int minimum = 1;
	int maximum = 128;
	int step = 1;
> = 20;

uniform float BorderStrength <
	string name = "Border Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.05;

uniform int BorderThickness <
	string name = "Border Thickness";
	string widget_type = "slider";
	int minimum = 0;
	int maximum = 64;
	int step = 1;
> = 1;

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float2 P1 <
	string name = "Point 1";
	string widget_type = "slider";
	float step = 0.01;
	float2 minimum = { 0.0, 0.0 };
	float2 maximum = { 1.0, 1.0 };
> = { 0.0, 0.0 };

uniform float2 P2 <
	string name = "Point 2";
	string widget_type = "slider";
	float step = 0.01;
	float2 minimum = { 0.0, 0.0 };
	float2 maximum = { 1.0, 1.0 };
> = { 1.0, 0.0 };

uniform float2 P3 <
	string name = "Point 3";
	string widget_type = "slider";
	float step = 0.01;
	float2 minimum = { 0.0, 0.0 };
	float2 maximum = { 1.0, 1.0 };
> = { 1.0, 1.0 };

uniform float2 P4 <
	string name = "Point 4";
	string widget_type = "slider";
	float step = 0.01;
	float2 minimum = { 0.0, 0.0 };
	float2 maximum = { 1.0, 1.0 };
> = { 0.0, 1.0 };



float4 mainImage(VertData v_in) : TARGET
{	
	float4 color;
	float2 uv = v_in.uv;

	color = image.Sample(clamp_texture_sampler, uv);

	if (PointInQuad(uv, P1, P2, P3, P4))
	{
		float aspect = uv_size.x / uv_size.y;
		uv -= 0.5;
		uv.x *= aspect;

		float scale = uv_pixel_interval.x * CellSize;
		float2 tileCenter = (floor(uv / scale) + 0.5) * scale;
		float2 tileToTexel = abs(tileCenter - uv);
		tileCenter.x /= aspect;
		tileCenter += 0.5;

		float4 cellColor = image.Sample(clamp_texture_sampler, tileCenter);
		
		float dist = max(tileToTexel.x, tileToTexel.y);
		if (dist > uv_pixel_interval.x * (CellSize / 2 - BorderThickness))
			cellColor *= 1 - BorderStrength;

		color = lerp(color, cellColor, Strength);
	}
	

	return color;
}