#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Depth <
	string name = "Depth";
	string widget_type = "slider";
	float minimum = -0.5;
	float maximum = 0.5;
	float step = 0.001;
> = 0;

uniform bool UseRightEyeTexture <
	string name = "Use Right Eye Texture";
> = false;

uniform texture2d RightEyeTexture <
	string name = "Right Eye Texture";
	string widget_type = "input";
	bool automatic = false;
>;



float4 mainImage(VertData v_in) : TARGET
{	
	float2 offset = float2(Depth, 0) * uv_size * 0.5;
	
	float2 uvR = v_in.uv + offset * uv_pixel_interval;
	float2 uvC = v_in.uv - offset * uv_pixel_interval;

	float4 colorR = image.Sample(border_texture_sampler, uvR);
	float4 colorC;

	if (UseRightEyeTexture)
	{
		colorC = RightEyeTexture.Sample(border_texture_sampler, uvC);
	}
	else
	{
		colorC = image.Sample(border_texture_sampler, uvC);
	}

	float lumaR = RgbToLuma(colorR.rgb);
	float lumaC = RgbToLuma(colorC.rgb);

	return float4(lumaR, lumaC, lumaC, min(colorR.a, colorC.a));
}