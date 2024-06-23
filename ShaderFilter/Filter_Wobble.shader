#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float XFrequency <
	string name = "Horizontal Frequency";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 1;

uniform float XScale <
	string name = "Horizontal Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 1;

uniform float XPhase <
	string name = "Horizontal Phase";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float YFrequency <
	string name = "Vertical Frequency";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 1;

uniform float YScale <
	string name = "Vertical Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 1;

uniform float YPhase <
	string name = "Vertical Phase";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;


uniform float XNoiseScale <
	string name = "Horizontal Noise Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 0;

uniform float YNoiseScale <
	string name = "Vertical Noise Scale";
	string widget_type = "slider";
	float step = 1;
	float minimum = 0;
	float maximum = 512;
> = 0;

#define BORDERMODE_NONE		0
#define BORDERMODE_WRAP		1
#define BORDERMODE_CLAMP	2
#define BORDERMODE_MIRROR	3

uniform int BorderMode <
	string label = "Texture Border Mode";
	string widget_type = "select";
	int option_0_value = BORDERMODE_NONE;
	string option_0_label = "None";
	int option_1_value = BORDERMODE_WRAP;
	string option_1_label = "Wrap";
	int option_2_value = BORDERMODE_CLAMP;
	string option_2_label = "Clamp";	
	int option_3_value = BORDERMODE_MIRROR;
	string option_3_label = "Mirror";
> = BORDERMODE_NONE;


float4 mainImage(VertData v_in) : TARGET
{	
	float2 rand = float2(rand_f, frac((rand_f + 1) * 7.392398197));

	float2 offset = 0;

	offset.x += sin(elapsed_time * XFrequency + XPhase * PI * 2) * XScale;
	offset.y += cos(elapsed_time * YFrequency + YPhase * PI * 2) * YScale;

	offset += (rand * 2 - 1) * float2(XNoiseScale , YNoiseScale);

	float2 uv = v_in.uv + offset * uv_pixel_interval;

	if (BorderMode == BORDERMODE_WRAP)
		uv = frac(uv);
	else if (BorderMode == BORDERMODE_CLAMP)
		uv = saturate(uv);
	else if (BorderMode == BORDERMODE_MIRROR)
		uv = abs(abs(uv - 1) - 1);

	float clip = step(0, uv.x) * step(uv.x, 1) * step(0, uv.y) * step(uv.y, 1);

	float4 color = image.Sample(clamp_texture_sampler, uv) * clip;

	return color;
}