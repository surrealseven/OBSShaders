#include "SourceShader.h"
#include "ShaderCommon.h"

uniform float RingCount <
	string name = "Ring Count";
	string widget_type = "slider";
	float minimum = 0.1;
	float maximum = 50.0;
	float step = 0.01;
> = 15;

uniform float ZoomSpeed <
	string name = "Zoom Speed";
	string widget_type = "slider";
	float minimum = -10;
	float maximum = 10;
	float step = 0.01;
> = 0.1;

uniform float Zoom <
	string name = "Zoom";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 100;
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

uniform float Skew <
	string name = "Skew";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 100;
	float step = 0.01;
> = 0;

uniform float SkewAngle <
	string name = "Skew Angle";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 360;
	float step = 0.01;
> = 0.5;

uniform float RotationSpeed <
	string name = "Rotation Speed";
	string widget_type = "slider";
	float minimum = -360;
	float maximum = 360;
	float step = 0.01;
> = 0;

uniform float Linearity <
	string name = "Thickness Linearity";
	string widget_type = "slider";
	float minimum = 0.001;
	float maximum = 2;
	float step = 0.01;
> = 1;

uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;


float4 CalculateColor(float2 position, float2 center)
{
	float theta = elapsed_time * RotationSpeed + SkewAngle;
	float2 skew = float2(sin(theta * DEG2RAD), cos(theta * DEG2RAD));

	float2 delta = position - center;
	float dist = pow(length(delta), Linearity) + dot(skew, delta) * Skew * 0.01;

	float t = abs(fmod(dist * RingCount - elapsed_time * ZoomSpeed + Zoom * 0.01, 2));

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