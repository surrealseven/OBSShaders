#include "SourceShader.h"
#include "ShaderCommon.h"

uniform float XSpeed <
	string name = "X Speed";
	string widget_type = "slider";
	float minimum = -5;
	float maximum = 5;
	float step = 0.01;
> = 0;

uniform float YSpeed <
	string name = "Y Speed";
	string widget_type = "slider";
	float minimum = -5;
	float maximum = 5;
	float step = 0.01;
> = 0.1;

uniform float XFreq <
	string name = "X Frequency";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 10;
	float step = 0.01;
> = 1.5;

uniform float YFreq <
	string name = "Y Frequency";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 30;
	float step = 0.01;
> = 10;

uniform float ZHeight <
	string name = "Z Height";
	string widget_type = "slider";
	float minimum = -1;
	float maximum = 1;
	float step = 0.01;
> = 0;

uniform float Perspective <
	string name = "Perspective";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.9;

uniform float Thickness <
	string name = "Thickness";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.5;

uniform float3 Color <
	string name = "Color";
> = { 1.5, 1, 1.5 };

uniform float ColorScale <
	string name = "Color Scale";
	string widget_type = "slider";
	float minimum = 1;
	float maximum = 10;
	float step = 0.01;
> = 2;

uniform float4 Background <
	string name = "Background";
> = { 0, 0, 0, 1 };


uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 1;

float4 mainImage(VertData v_in) : TARGET
{	
	float2 uv = v_in.uv * 2 - 1;
	uv.x *= uv_size.x / uv_size.y;
	uv.y -= ZHeight;

	float d = length(uv);
	
	float fovT = lerp(0.0, 0.99, Perspective);
	float z = max(((uv.y - 1) * 0.5 + 0.5), 0) * fovT + (1 - fovT);
	
	float px = uv.x / z;
	float py = uv.y / z;	

	float xLine = abs(frac((px + elapsed_time * XSpeed) * XFreq) * 2 - 1);
	float yLine = abs(frac((py + elapsed_time * -YSpeed) * YFreq) * 2 - 1);

	float thickness = lerp(0.001, 0.1, Thickness);
	d = saturate((thickness / xLine) + (thickness / yLine));
	d *= smoothstep(0, 0.5, uv.y);

	// d = sin(d * 8 + elapsed_time) / 8;
	// d = abs(d);
	// d = 0.18 / d;

	float4 color = lerp(Background, float4(Color * ColorScale, 1), d);
	color.a *= Opacity;
	return color;
}