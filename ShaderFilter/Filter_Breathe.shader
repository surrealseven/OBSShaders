#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Frequency <
	string name = "Frequency";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 20;
> = 1;

uniform float Scale <
	string name = "Scale";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.1;

uniform float Phase <
	string name = "Phase";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;


uniform float NoiseScale <
	string name = "Noise Scale";
	string widget_type = "slider";
	float step = 0.001;
	float minimum = 0;
	float maximum = 0.1;
> = 0;

uniform float CenterX <
	string name = "Center X";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.5;

uniform float CenterY <
	string name = "Center Y";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.5;

#define BORDERMODE_NONE		0
#define BORDERMODE_WRAP		1
#define BORDERMODE_CLAMP	2
#define BORDERMODE_MIRROR	3

uniform int BorderType <
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
	float scale = 1.0 - (sin(elapsed_time * Frequency + Phase * PI * 2) * 0.5 + 0.5) * Scale;

	scale += (rand_f * 2 - 1) * NoiseScale;
	scale = max(scale, 0.0);

	float2 center = float2(CenterX, CenterY);
	float2 uv = (v_in.uv - center) / scale + center;

	if (BorderType == BORDERMODE_WRAP)
		uv = frac(uv);
	else if (BorderType == BORDERMODE_CLAMP)
		uv = saturate(uv);
	else if (BorderType == BORDERMODE_MIRROR)
		uv = abs(abs(uv - 1) - 1);

	float clip = step(0, uv.x) * step(uv.x, 1) * step(0, uv.y) * step(uv.y, 1);

	float4 color = image.Sample(border_texture_sampler, uv) * clip;

	return color;
}