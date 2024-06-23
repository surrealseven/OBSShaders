#include "SourceShader.h"
#include "ShaderCommon.h"

uniform float RingCount <
	string name = "Ring Count";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 50.0;
	float step = 0.01;
> = 13;

uniform int CenterCount <
	string name = "Center Count";
	string widget_type = "slider";
	int minimum = 2;
	int maximum = 3;
	int step = 1;
> = 2;

uniform float Speed <
	string name = "Speed";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 2;
	float step = 0.01;
> = 0.5;

uniform float ZoomSpeed <
	string name = "Zoom Speed";
	string widget_type = "slider";
	float minimum = -10;
	float maximum = 10;
	float step = 0.01;
> = 0.6;

uniform float MoveScale <
	string name = "Movement Scale";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 2;
	float step = 0.01;
> = 1.6;

uniform float Smooth <
	string name = "Border Smoothing";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.13;

uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

float4 CalculateColor(float2 position, float2 center)
{
	float dist = distance(position, center);

	float t = abs(fmod(dist * RingCount - elapsed_time * ZoomSpeed, 2));

	float border = (1.0 - Smooth) * 0.5;
	float color = smoothstep(border, 1 - border, t) * smoothstep(border, 1 - border, 2 - t);
	
	return float4(color, color, color, 1);
}

float4 mainImage(VertData v_in) : TARGET
{	
	float aspect = uv_size.x / uv_size.y;

	float2 uv = v_in.uv * float2(aspect, 1);

	float4 params[] =
	{
		float4(0.5, 0.7, 0.13, 0.17),
		float4(0.6, 0.2, 0.09, 0.09),
		float4(0.3, 0.5, 0.12, 0.17),
	};

	float4 color = 0;

	float t = elapsed_time * Speed;

	for (int i = 0; i < CenterCount; i++)
	{
		float4 p = params[i];
		float cx = (0.5 + sin(PI * 2 * t * p.x) * p.z * MoveScale) * aspect;
		float cy = 0.5 + cos(PI * 2 * t * p.y) * p.w * MoveScale;

		float4 c = CalculateColor(uv, float2(cx, cy));

		color = abs(color - c);
	}

	color.a = Opacity;

	return color;
}