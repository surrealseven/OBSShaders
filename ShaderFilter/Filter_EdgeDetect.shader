#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float4 BackgroundColor <
	string name = "Background Color";
> = { 1.0, 1.0, 1.0, 1.0 };

uniform float Spread <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 5.0;
	float step = 0.1;
> = 1.5;

uniform float LowThreshold <
	string name = "Low Threshold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float HighThreshold <
	string name = "High Threshold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 1.0;

uniform float EdgeBias <
	string name = "Edge Bias";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 5.0;
	float step = 0.01;
> = 3.0;

uniform float Fade <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.1;

uniform float AlphaFade <
	string name = "Alpha Fade";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float Desaturation <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;



float4 mainImage(VertData v_in) : TARGET
{	
	float2 center = v_in.uv;
	float2 range = uv_pixel_interval * Spread;


	float4 realColor = image.Sample(clamp_texture_sampler, v_in.uv);

	float4 h = image.Sample(clamp_texture_sampler, center + float2(range.x, 0)) -
			   image.Sample(clamp_texture_sampler, center - float2(range.x, 0));
	float4 v = image.Sample(clamp_texture_sampler, center + float2(0, range.y)) -
			   image.Sample(clamp_texture_sampler, center - float2(0, range.y));

	float4 color = 1.0 - max(abs(h), abs(v));

	float luma = RgbToLuma(color.rgb);
	luma = smoothstep(LowThreshold, HighThreshold, luma);
	luma = pow(luma, EdgeBias);

	color = lerp(realColor, BackgroundColor, luma);
	color = lerp(color, luma, Desaturation);
	
	color = lerp(color, realColor, Fade);
	color.a = lerp(1, realColor.a, AlphaFade);

	return color;
}