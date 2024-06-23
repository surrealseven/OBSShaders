#include "FilterShader.h"
#include "ShaderCommon.h"

#define MASK_TYPE_CIRCLE		0
#define MASK_TYPE_SQUARE		1
#define MASK_TYPE_CROSS			2
#define MASK_TYPE_LETTERBOX		3

uniform int MaskType <
	string label = "Mask Type";
	string widget_type = "select";
	int option_0_value = MASK_TYPE_CIRCLE;
	string option_0_label = "Circle";
	int option_1_value = MASK_TYPE_SQUARE;
	string option_1_label = "Square";
	int option_2_value = MASK_TYPE_CROSS;
	string option_2_label = "Cross";	
	int option_3_value = MASK_TYPE_LETTERBOX;
	string option_3_label = "Letterbox";
> = MASK_TYPE_CIRCLE;

uniform bool Invert = false;

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

uniform float Radius <
	string name = "Radius";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1.1;
> = 0.5;

uniform float Smooth <
	string name = "Border Smoothing";
	string widget_type = "slider";
	float minimum = 0;
	float maximum = 1;
	float step = 0.01;
> = 0.13;

uniform float Amount <
	string name = "Amount";
	string field_type = "slider";
	float minimum = 0;
	float maximum = 100;
	float step = 0.01;
> = 10;

uniform float Rotation <
	string name = "Rotation";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 360;
> = 0;



float4 CircleMask(VertData v_in)
{
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);
	
	float2 center = float2(CenterX, CenterY);
	float2 srcUv = v_in.uv - float2(0.5, 0.5);
	srcUv.x *= uv_size.x / uv_size.y;

	float dist = distance(center, srcUv);

	float alpha = 1.0 - (smoothstep(Radius - Smooth * 0.5, Radius + Smooth * 0.5, dist) / (Radius + Smooth));
	if (Invert)
		alpha = 1.0 - alpha;

	color.a *= alpha;

	return color;
}

float4 SquareMask(VertData v_in)
{	
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);
	
	float2 center = float2(CenterX, CenterY);
	float2 srcUv = v_in.uv - float2(0.5, 0.5);
	srcUv.x *= uv_size.x / uv_size.y;

	float s, c;
	sincos(Rotation / 180 * PI, s, c);
	float2x2 mat = { c, -s, s, c };
	srcUv = mul(srcUv, mat);

	float2 delta = abs(srcUv - center);
	float dist = max(delta.x, delta.y);

	float alpha = 1.0 - (smoothstep(Radius - Smooth * 0.5, Radius + Smooth * 0.5, dist) / (Radius + Smooth));
	if (Invert)
		alpha = 1.0 - alpha;

	color.a *= alpha;

	return color;
}

float4 CrossMask(VertData v_in)
{
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	float2 center = float2(CenterX, CenterY);
	float2 srcUv = v_in.uv - float2(0.5, 0.5);
	srcUv.x *= uv_size.x / uv_size.y;

	float s, c;
	sincos(Rotation / 180 * PI, s, c);
	float2x2 mat = { c, -s, s, c };
	srcUv = mul(srcUv, mat);

	float2 delta = abs(srcUv - center);
	float dist = min(delta.x, delta.y);

	float alpha = 1.0 - (smoothstep(Radius - Smooth * 0.5, Radius + Smooth * 0.5, dist) / (Radius + Smooth));
	if (Invert)
		alpha = 1.0 - alpha;

	color.a *= alpha;

	return color;
}

float4 LetterboxMask(VertData v_in)
{
	float4 color = image.Sample(clamp_texture_sampler, v_in.uv);

	float t = abs(v_in.uv.y - 0.5) * 2.0;

	float thresh = 1.0 - (Amount * 0.01);
	float alpha = 1.0 - smoothstep(thresh - Smooth * 0.5, thresh + Smooth * 0.5, t);
	if (Invert)
		alpha = 1.0 - alpha;

	color.a *= alpha;

	return color;
}


float4 mainImage(VertData v_in) : TARGET
{
	if (MaskType == MASK_TYPE_SQUARE)
	 	return SquareMask(v_in);
	if (MaskType == MASK_TYPE_CROSS)
		return CrossMask(v_in);
	if (MaskType == MASK_TYPE_LETTERBOX)
		return LetterboxMask(v_in);
	return CircleMask(v_in);	
}
