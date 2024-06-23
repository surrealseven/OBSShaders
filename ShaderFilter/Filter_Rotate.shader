#include "FilterShader.h"
#include "ShaderCommon.h"

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

uniform float Phase <
	string name = "Rotation";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 360;
> = 0.5;

uniform float Speed <
	string name = "Rotation Speed";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -180;
	float maximum = 180;
> = 0;

uniform float WobbleSpeed <
	string name = "Wobble Speed";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 2;
> = 1;

uniform float WobbleStrength <
	string name = "Wobble Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 360;
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
	float theta = frac(elapsed_time * Speed) * PI * 2;
	theta += (sin(elapsed_time * WobbleSpeed * PI * 2) * WobbleStrength - Phase) * DEG2RAD;

	float s, c;
	sincos(theta, s, c);

	float2 center = float2(CenterX, CenterY);
	float2 uv = v_in.uv;
	
	uv = (uv - center) * uv_size;
	uv = float2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
	uv = uv * uv_pixel_interval + center;

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