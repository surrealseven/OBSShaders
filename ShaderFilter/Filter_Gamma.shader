#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float GammaR <
	string name = "Red";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 3.0;
	float step = 0.01;
> = 1;

uniform float GammaG <
	string name = "Green";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 3.0;
	float step = 0.01;
> = 1;

uniform float GammaB <
	string name = "Blue";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 3.0;
	float step = 0.01;
> = 1;

uniform float GammaOffset <
	string name = "Global Offset";
	string widget_type = "slider";
	float minimum = -3.0;
	float maximum = 3.0;
	float step = 0.01;
> = 0;

uniform float Contrast <
	string name = "Contrast";
	string widget_type = "slider";
	float minimum = -1.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0;


float4 mainImage(VertData v_in) : TARGET
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	color.r = pow(color.r, GammaR + GammaOffset);
	color.g = pow(color.g, GammaG + GammaOffset);
	color.b = pow(color.b, GammaB + GammaOffset);
	
	color = saturate(color);

	
	color.r = pow(abs(color.r * 2 - 1), 1 - Contrast) * sign(color.r * 2 - 1) * 0.5 + 0.5;
	color.g = pow(abs(color.g * 2 - 1), 1 - Contrast) * sign(color.g * 2 - 1) * 0.5 + 0.5;
	color.b = pow(abs(color.b * 2 - 1), 1 - Contrast) * sign(color.b * 2 - 1) * 0.5 + 0.5;

	return color;
}