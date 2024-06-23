#include "SourceShader.h"
#include "ShaderCommon.h"

uniform int ArmCount <
	string name = "Arm Count";
	string widget_type = "slider";
	int minimum = 1;
	int maximum = 30;	
> = 1;

uniform float Linearity <
	string name = "Thickness Linearity";
	string widget_type = "slider";
	float minimum = 0.01;
	float maximum = 2;
	float step = 0.01;
> = 1;

uniform float Rotation <
	string name = "Rotation";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 360;
	float step = 0.01;
> = 0;

uniform float Speed <
	string name = "Rotation Speed";
	string widget_type = "slider";
	float minimum = -20;
	float maximum = 20;
	float step = 0.01;
> = 0;

uniform float Smooth <
	string name = "Border Smoothing";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.13;

uniform float CenterX <
	string name = "Center X";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.001;
> = 0.5;

uniform float CenterY <
	string name = "Center Y";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.001;
> = 0.5;

uniform float Curve <
	string name = "Spiral Curve";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 100;
	float step = 0.01;
> = 10;

#define HANDEDNESS_RIGHT	0
#define HANDEDNESS_LEFT		1

uniform int Handedness <
	string label = "Handedness";
	string widget_type = "select";
	int option_0_value = HANDEDNESS_RIGHT;
	string option_0_label = "Right";
	int option_1_value = HANDEDNESS_LEFT;
	string option_1_label = "Left";
> = HANDEDNESS_RIGHT;

uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;


float4 CalculateColor(float2 position, float2 center)
{
	float2 dir = position - center;

	float theta = (atan2(dir.x, dir.y) / PI) * 0.5 + 0.5;
	theta = abs(Handedness - theta);
	theta = frac(theta + Rotation / 360);

	float dist = pow(length(dir), Linearity) * Curve + theta * (ArmCount * 2);

	float t = abs(fmod(dist - elapsed_time * Speed, 2));

	float border = (1.0 - Smooth) * 0.5;
	float color = smoothstep(border, 1 - border, t) * smoothstep(border, 1 - border, 2 - t);

	return float4(color, color, color, 1);

}



float4 mainImage(VertData v_in) : TARGET
{	
	float aspect = uv_size.x / uv_size.y;

	float2 uv = v_in.uv * float2(aspect, 1);

	float4 color = 0;

	color = CalculateColor(uv, float2(CenterX * aspect, CenterY));
	color.a = Opacity;

	return color;
}
