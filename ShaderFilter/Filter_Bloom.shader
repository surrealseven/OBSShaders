#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Threshold <
	string name = "Threshold";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.5;

uniform float Smoothing <
	string name = "Smoothing";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.1;

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 2;
> = 0.5;

uniform int BlurQuality <
	string name = "Blur Quality";
	string widget_type = "slider";	
	int minimum = 1;
	int maximum = 16;
> = 3;

uniform int BlurSize <
	string name = "Blur Size";
	string widget_type = "slider";	
	int minimum = 2;
	int maximum = 64;
> = 24;

uniform int BlurSteps <
	string name = "Blur Steps";
	string widget_type = "slider";
	int minimum = 1;
	int maximum = 32;
> = 16;



float4 FetchBloom(float2 uv)
{
	float4 color;
	
	const int kernelSize = 12;

	float upperThreshold = Threshold + (1 - Threshold) * Smoothing;

	color = image.Sample(clamp_texture_sampler, uv);
	for (int u = -kernelSize / 2; u < (kernelSize + 1) / 2; u++)
	{
		for (int v = -kernelSize / 2; v < (kernelSize + 1) / 2; v++)
		{
			float2 offset = (float2(u, v) * 4.0 - 0.5) * ViewSize.zw;
			float4 c = image.Sample(clamp_texture_sampler, uv + offset);
			float luma = RgbToLuma(c.rgb);

			float t = smoothstep(Threshold, upperThreshold, luma);
			
			color += c * t;
		}
	}

	color /= kernelSize * kernelSize;

	return color;
}

float4 FetchGaussianBloom(float2 uv)
{
	float2 radius = (float)BlurSize * uv_pixel_interval;

	float4 color = image.Sample(clamp_texture_sampler, uv);

	float upperThreshold = Threshold + (1 - Threshold) * Smoothing;

	for (int j = 0; j < BlurSteps; j++)
	{
		float d = PI * 2 * j / BlurSteps;
		float2 dcs = float2(cos(d), sin(d)) * radius;
		float invQuality = 1.0 / BlurQuality;

		for (int i = 1; i <= BlurQuality; i++)
		{
			float q = invQuality * i;

			float4 c = image.Sample(clamp_texture_sampler, uv + dcs * q);
			float luma = RgbToLuma(c.rgb);
			float t = smoothstep(Threshold, upperThreshold, luma);
			
			color += c * t;
		}
	}
	
	color /= BlurQuality * BlurSteps + 1;
	return color;
}


float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);
	
	float4 blurred = FetchGaussianBloom(v_in.uv);

	float blurredLuma = RgbToLuma(blurred.rgb);

	color.rgb = saturate(color.rgb + blurred.rgb * Strength);

	return color;
}