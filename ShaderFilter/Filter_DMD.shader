#include "FilterShader.h"
#include "ShaderCommon.h"


uniform float LedSize <
	string name = "Led Size";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 100.0;
	float step = 1.0;
> = 16.0;

uniform float LedFatness <
	string name = "Led Fatness";
	string widget_type = "slider";
	float minimum = 0.25;
	float maximum = 5.0;
	float step = 0.01;
> = 1.0;

uniform int IntensitySteps <
	string name = "Intensity Steps";
	string widget_type = "slider";
	int minimum = 0;
	int maximum = 255;
	int step = 1;
> = 3;

uniform float Brightness <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 5.0;
	float step = 0.1;
> = 1.0;

uniform float Contrast <
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 5.0;
	float step = 0.01;
> = 1.0;

uniform float Fade <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 1.0;

uniform bool Monochrome = true;
uniform bool Smooth = false;

uniform float4 UnlitColor <
	string name = "Unlit Color";
> = { 0.1, 0.025, 0.0, 1.0 };

uniform float4 LitColor <
	string name = "Lit Color";
> = { 1.0, 0.25, 0.0, 1.0 };

uniform float4 BackgroundColor <
	string name = "Background Color";
> = { 0.0, 0.0, 0.0, 1.0 };


float4 mainImage(VertData v_in) : TARGET
{	
	float2 ledUV = uv_pixel_interval * LedSize;
	float2 pix = v_in.uv;
	float2 tileCorner = floor(pix / ledUV) * ledUV;
	float2 tileCenter = tileCorner + ledUV * 0.5;

	// get the color in the middle of the screen tile
	float4 color = image.Sample(clamp_texture_sampler, tileCenter);

	if (Smooth)
	{
		float2 sampleOffset = ledUV * 0.25;
		color += image.Sample(clamp_texture_sampler, tileCenter + sampleOffset);
		color += image.Sample(clamp_texture_sampler, tileCenter - sampleOffset);
		sampleOffset.x *= -1;
		color += image.Sample(clamp_texture_sampler, tileCenter + sampleOffset);
		color += image.Sample(clamp_texture_sampler, tileCenter - sampleOffset);
		color /= 5;
	}


	// calculate luminance and apply shaping
	if (Monochrome)
	{
		float gray = RgbToLuma(color.rgb);
		gray *= Brightness;
		gray = (gray - 0.5) * Contrast + 0.5;

		gray = round(gray * IntensitySteps) / IntensitySteps;
		gray = clamp(gray, 0.0, 1.0);
		color = lerp(UnlitColor, LitColor, gray);
	}
	else
	{
		float3 oneHalf = { 0.5, 0.5, 0.5 };
		color.xyz *= Brightness;
		color.xyz = (color.xyz - oneHalf) * Contrast + oneHalf;
		color.xyz = floor(color.xyz * IntensitySteps) / IntensitySteps;
	}

	float dist = length((v_in.uv - tileCenter) / ledUV) * 2.0;
	dist = pow(dist, LedFatness);
	float4 bgColor = BackgroundColor;
	color = lerp(color, bgColor, dist);

	if (Fade < 1.0)
	{
		float4 srcColor = image.Sample(clamp_texture_sampler, v_in.uv);
		color = lerp(srcColor, color, Fade);
	}

	return color;
}