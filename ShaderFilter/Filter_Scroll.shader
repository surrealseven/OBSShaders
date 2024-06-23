#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float XOffset <
	string name = "Horizontal Offset";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0;

uniform float XSpeed <
	string name = "Horizontal Speed";
	// string widget_type = "slider";
	// float minimum = -4090;
	// float maximum = 4090;
	// float step = 1;
> = 0;

uniform int XStep <
	string name = "Horizontal Step";
	string widget_type = "slider";
	int minimum = 0;
	int maximum = 4098;
	int step = 1;
> = 0;

uniform float YOffset <
	string name = "Vertical Offset";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0;

uniform float YSpeed <
	string name = "Vertical Speed";
	// string widget_type = "slider";
	// float minimum = -4090;
	// float maximum = 4090;
	// float step = 1;
> = 0;

uniform int YStep <
	string name = "Vertical Step";
	string widget_type = "slider";
	int minimum = 0;
	int maximum = 4098;
	int step = 1;
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
> = BORDERMODE_WRAP;


float4 mainImage(VertData v_in) : TARGET
{	
	float2 speed = float2(XSpeed, YSpeed);

	// we do this fmod to ensure the quantization step works on a decent number range.
	// over time there isn't enough floating point precision and artifacts manifest.
	float2 offset = float2(XOffset, YOffset) * uv_size + fmod(elapsed_time * speed, uv_size * 2);
	if (XStep > 0)
		offset.x = trunc(offset.x / XStep) * XStep;
	if (YStep > 0)
		offset.y = trunc(offset.y / YStep) * YStep;
	
	float2 uv = frac((v_in.uv + offset * uv_pixel_interval) * 0.5) * 2;

	if (BorderMode == BORDERMODE_WRAP)
		uv = frac(uv);
	else if (BorderMode == BORDERMODE_CLAMP)
		uv = saturate(uv);
	else if (BorderMode == BORDERMODE_MIRROR)
		uv = abs(abs(uv - 1) - 1);

	float clip = step(0, uv.x) * step(uv.x, 1) * step(0, uv.y) * step(uv.y, 1);
	float4 color = image.Sample(border_texture_sampler, uv) * clip;

	return color;
}