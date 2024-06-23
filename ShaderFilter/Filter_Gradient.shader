#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Strength <
	string label = "Strength";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 1;

uniform bool PreserveAlpha <
	string label = "Preserve Alpha";
> = true;

uniform bool MaintainAspect <
	string label = "Maintain Aspect Ratio";
> = true;

#define GRADIENT_TYPE_LINEAR 0
#define GRADIENT_TYPE_IRIS   1
#define GRADIENT_TYPE_RADIAL 2

uniform int GradientType <
  string label = "Gradient Type";
  string widget_type = "select";
  int    option_0_value = GRADIENT_TYPE_LINEAR;
  string option_0_label = "Linear";
  int    option_1_value = GRADIENT_TYPE_IRIS;
  string option_1_label = "Iris";
  int    option_2_value = GRADIENT_TYPE_RADIAL;
  string option_2_label = "Radial";
> = GRADIENT_TYPE_LINEAR;

uniform float CyclesPerSecond <
	string label = "Cycles Per Second";
	string widget_type = "slider";
	float minimum = -10.0;
	float maximum = 10.0;
	float step = 0.01;
> = 0.0;

uniform float CyclePhase <
	string label = "Cycle Phase";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float RotationsPerSecond <
	string label = "Rotations Per Second";
	string widget_type = "slider";
	float minimum = -10.0;
	float maximum = 10.0;
	float step = 0.01;
> = 0.0;

uniform float RotationPhase <
	string label = "Rotation Phase";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float Zoom <
	string label = "Zoom";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 10.0;
	float step = 0.01;
> = 1.0;


uniform int ColorCount <
	string label = "Color Count";
	string widget_type = "slider";
	int minimum = 2;
	int maximum = 8;
> = 4;

uniform bool WrapColors <
	string label = "Wrap Colors";
> = true;

uniform float4 Color1 <
	string name = "Color 1";
> = { 1, 0, 1, 1 };
 
uniform float4 Color2 <
	string name = "Color 2";
> = { 0.5, 0, 1, 1 };

uniform float4 Color3 <
	string name = "Color 3";
> = { 0, 0, 1, 1 };

uniform float4 Color4 <
	string name = "Color 4";
> = { 0, 1, 1, 1 };

uniform float4 Color5 <
	string name = "Color 5";
> = { 0, 1, 0, 1 };

uniform float4 Color6 <
	string name = "Color 6";
> = { 1, 1, 0, 1 };

uniform float4 Color7 <
	string name = "Color 7";
> = { 1, 0.5, 0, 1 };

uniform float4 Color8 <
	string name = "Color 8";
> = { 1, 0, 0, 1 };


float4 Palette(float t)
{
	float4 colors[] = { Color1, Color2, Color3, Color4, Color5, Color6, Color7, Color8, Color1 };
	int colorCount = ColorCount + (WrapColors ? 1 : 0);
	colors[ColorCount] = Color1;

	t = frac(t);

	float phase = t * float(colorCount - 1);
	float idx = floor(phase);
	phase -= idx;

	float4 color1 = colors[int(idx)];
	float4 color2 = colors[int(idx + 1)];

	float4 color = lerp(color1, color2, phase);

	return color;
}




float4 mainImage(VertData v_in) : TARGET
{
	float4 srcColor = image.Sample(border_texture_sampler, v_in.uv);

	float2 uv = v_in.uv * 2 - 1;

	if (MaintainAspect)
		uv.x *= uv_size.x / uv_size.y;	

	uv = mul(uv, MakeRotation2D(RotationPhase * TWOPI + RotationsPerSecond * elapsed_time)) * Zoom;
	

	float t;

	switch (GradientType)
	{
		case GRADIENT_TYPE_LINEAR:
		default:
			t = uv.x * 0.5 + 0.5;
			break;

		case GRADIENT_TYPE_IRIS:
			t = length(uv);
			break;

		case GRADIENT_TYPE_RADIAL:
			t = atan2(uv.x, uv.y) / TWOPI;
			break;
	}

	t += CyclePhase + CyclesPerSecond * elapsed_time;

	float4 gradColor = Palette(t);
	float4 color = lerp(srcColor, gradColor, Strength);

	if (PreserveAlpha)
		color.a *= srcColor.a;

	return color;
}