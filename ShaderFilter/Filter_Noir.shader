#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Hue <
	string name = "Hue";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -1;
	float maximum = 1;
> = 0;

uniform float HueSmooth <
	string name = "Hue Smoothing";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0;

uniform float Width <
	string name = "Width";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.1;

uniform float MinSaturation <
	string name = "Minimum Saturation";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0;

uniform float SaturationSmooth <
	string name = "Saturation Smoothing";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0;

uniform float SaturationBoost <
	string name = "Saturation Boost";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0;

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Contrast <
	string name = "Contrast";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -1;
	float maximum = 1;
> = 0;



float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);
	
	float3 hsv = RgbToHsv(color.rgb);

	float luma = RgbToLuma(color.rgb);

	float value = luma * 2.0 - 1.0;
	luma = pow(abs(value), 1.0 - Contrast) * sign(value) * 0.5 + 0.5;

	float dist = min(abs(hsv.x - Hue * 0.5), abs(1.0 - hsv.x + Hue * 0.5));

	float t = 1.0 - smoothstep(Width - HueSmooth * 0.5, Width, dist);
	t *= smoothstep(MinSaturation - SaturationSmooth * 0.5, MinSaturation, hsv.y);
	t = 1.0 - ((1.0 - t) * Strength);


	float3 noirColor = lerp(luma, color.rgb, t);

	//hsv.x = Hue;
	//hsv.y = 1.0 - pow(1.0 - hsv.y, SaturationBoost * 4 + 1);
	//hsv.z = 1.0 - pow(1.0 - hsv.z, SaturationBoost * 4 + 1);
	//noirColor = lerp(noirColor, HsvToRgb(hsv), 1);

	color.rgb = lerp(noirColor, color.rgb, t);

	return color;
}