#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float CenterX <
	string name = "Center X";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -1;
	float maximum = 1;
> = 0;

uniform float CenterY <
	string name = "Center Y";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -1;
	float maximum = 1;
> = 0;

uniform bool Wrap = false;

uniform float Curvature <
	string name = "Curvature";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0.5;
	float maximum = 50;
> = 10;

uniform float RotPhase <
	string name = "Rotation Phase";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 0;

uniform float RotSpeed <
	string name = "Rotation Speed";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -100;
	float maximum = 100;
> = 0;

uniform float Zoom <
	string name = "Zoom";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 0;

uniform float ZoomSpeed <
	string name = "Zoom Speed";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -100;
	float maximum = 100;
> = 0;


uniform float MinV <
	string name = "Minimum Y";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 0;

uniform float MaxV <
	string name = "Maximum Y";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 1;

uniform float MinDist <
	string name = "Minimum Distance";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 100;
> = 0.2;

uniform float MaxDist <
	string name = "Maximum Distance";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 120;
> = 0.95;

uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float InnerFade <
	string name = "Inner Fade";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 50;
> = 0;

uniform float OuterFade <
	string name = "Outer Fade";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 50;
> = 0;


sampler_state texture_sampler
{
	Filter = Linear;
	AddressU = Clamp;
	AddressV = Wrap;
	BorderColor = 00000000;
};

float4 mainImage(VertData v_in) : TARGET
{	
	float2 srcUv = v_in.uv;	
	srcUv -= float2(CenterX + 0.5, CenterY + 0.5);
	srcUv.x *= uv_size.x / uv_size.y;

	float2 destUv = srcUv;	

	float dist = distance(float2(0, 0), srcUv);
	float alpha = Opacity;

	float minDist = MinDist * 0.01;
	float maxDist = MaxDist * 0.01;
	if (!Wrap && ((dist < minDist) || (dist > maxDist)))
		alpha = 0.0;

	float y = frac((dist - minDist) / (maxDist - minDist));
	float zoom = elapsed_time * ZoomSpeed * 0.001 + Zoom * 0.01;
	
	alpha *= 1.0 - smoothstep(0.0, y, InnerFade * 0.01);
	alpha *= smoothstep(y, 1.0, 1.0 - OuterFade * 0.01);

	y = frac(y + zoom);
	y = pow(y, Curvature * 0.1);
	y = lerp(MinV * 0.01, MaxV * 0.01, 1.0 - y);
	
	float phase = frac(elapsed_time * RotSpeed * 0.01 + RotPhase * 0.01);	

	destUv.y = y;
	destUv.x = frac(atan2(srcUv.x, srcUv.y) / PI * 0.5 + 0.5 + phase);
	if (MinV < MaxV)
		destUv.x = 1.0 - destUv.x;

	float4 color = image.Sample(texture_sampler, destUv);
	color.a *= alpha;
	return color;
}