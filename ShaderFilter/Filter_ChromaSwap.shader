#include "FilterShader.h"
#include "ShaderCommon.h"

float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	float4 yCbCrA = RgbaToYCbCr(color);
	float4 yCrCbA = yCbCrA.xzyw;

	color = YCbCrToRgba(yCrCbA);
	return color;
}