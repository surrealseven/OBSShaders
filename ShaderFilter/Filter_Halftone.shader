#include "FilterShader.h"
#include "ShaderCommon.h"


#define HALFTONE_TYPE_LUMA	0
#define HALFTONE_TYPE_RGB	1
#define HALFTONE_TYPE_CMY	2
#define HALFTONE_TYPE_CMYK	3

uniform int HalftoneType <
  string label = "Halftone Type";
  string widget_type = "select";
  int    option_0_value = HALFTONE_TYPE_LUMA;
  string option_0_label = "Luma";
  int    option_1_value = HALFTONE_TYPE_RGB;
  string option_1_label = "RGB";
  int    option_2_value = HALFTONE_TYPE_CMY;
  string option_2_label = "CMY";
  int    option_3_value = HALFTONE_TYPE_CMYK;
  string option_3_label = "CMYK";
> = HALFTONE_TYPE_LUMA;

uniform float MinDotSize <
	string name = "Minimum Dot Size";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 128;
> = 10;

uniform float MaxDotSize <
	string name = "Maximum Dot Size";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 128;
> = 30;

uniform float DotSmooth <
	string name = "Dot Smoothing";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 64;
> = 10;

uniform float DotBloom <
	string name = "Dot Bloom";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 64;
> = 0;

uniform float Intensity <
	string name = "Intensity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0.25;
	float maximum = 4.0;
> = 1;

uniform float Opacity <
	string name = "Opacity";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Angle <
	string name = "Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.1;

uniform float CAngle <
	string name = "C Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.06;

uniform float MAngle <
	string name = "M Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.18;

uniform float YAngle <
	string name = "Y Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.14;

uniform float KAngle <
	string name = "K Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.03;

uniform float RAngle <
	string name = "R Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.05;

uniform float GAngle <
	string name = "G Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.15;

uniform float BAngle <
	string name = "B Angle";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.25;



struct ColorData
{
	float4 color;
	float dist;
};

ColorData FetchColor(float2 uv, float angle)
{
	float aspect = uv_size.x / uv_size.y;
	float tileSize = max(MinDotSize, MaxDotSize);

	float2x2 rot = MakeRotation2D(angle * PI);
	float2x2 invRot = MakeRotation2D(-angle * PI);

	float2 scale = uv_pixel_interval.xx * tileSize;
	float2 rotatedUv = mul(rot, float2(uv.x * aspect, uv.y));
	float2 tileCenter = (floor(rotatedUv / scale) + 0.5) * scale;
	float dist = distance(rotatedUv, tileCenter);
	tileCenter = mul(invRot, tileCenter);
	tileCenter.x *= 1 / aspect;

	ColorData cd;
	cd.color = image.Sample(clamp_texture_sampler, tileCenter);
	cd.color.a = 1;
	cd.dist = dist;
	return cd;
}

float CalculateIntensity(float dist, float t)
{
	t = pow(saturate(t), Intensity);
	return smoothstep(dist - uv_pixel_interval.x * DotBloom, dist + uv_pixel_interval.x * DotSmooth, lerp(MinDotSize, MaxDotSize, t) * uv_pixel_interval.x * 0.5);
}

float4 CalculateComposite(float3 rgb, float2 uv)
{
	float4 rgba = float4(rgb.r, rgb.g, rgb.b, Opacity);
	return lerp(image.Sample(clamp_texture_sampler, uv), rgba, Strength);
}


float4 HalftoneLuma(VertData v_in) : TARGET
{
	ColorData cd = FetchColor(v_in.uv, Angle);
	float value = CalculateIntensity(cd.dist, RgbToLuma(cd.color));
	return CalculateComposite(float3(value, value, value), v_in.uv);
}

float4 HalftoneRgb(VertData v_in) : TARGET
{
	ColorData cdR = FetchColor(v_in.uv, RAngle);
	ColorData cdG = FetchColor(v_in.uv, GAngle);
	ColorData cdB = FetchColor(v_in.uv, BAngle);

	float r = cdR.color.r;
	float g = cdG.color.g;
	float b = cdB.color.b;

	r = CalculateIntensity(cdR.dist, r);
	g = CalculateIntensity(cdG.dist, g);
	b = CalculateIntensity(cdB.dist, b);

	return CalculateComposite(float3(r, g, b), v_in.uv);
}

float4 HalftoneCmy(VertData v_in) : TARGET
{
	ColorData cdC = FetchColor(v_in.uv, CAngle);
	ColorData cdM = FetchColor(v_in.uv, MAngle);
	ColorData cdY = FetchColor(v_in.uv, YAngle);

	float c = RgbToCmy(cdC.color.rgb).x;
	float m = RgbToCmy(cdM.color.rgb).y;
	float y = RgbToCmy(cdY.color.rgb).z;

	c = CalculateIntensity(cdC.dist, c);
	m = CalculateIntensity(cdM.dist, m);
	y = CalculateIntensity(cdY.dist, y);

	return CalculateComposite(CmyToRgb(float3(c, m, y)), v_in.uv);
}

float4 HalftoneCmyk(VertData v_in) : TARGET
{
	ColorData cdC = FetchColor(v_in.uv, CAngle);
	ColorData cdM = FetchColor(v_in.uv, MAngle);
	ColorData cdY = FetchColor(v_in.uv, YAngle);
	ColorData cdK = FetchColor(v_in.uv, KAngle);

	float c = RgbToCmyk(cdC.color.rgb).x;
	float m = RgbToCmyk(cdM.color.rgb).y;
	float y = RgbToCmyk(cdY.color.rgb).z;
	float k = RgbToCmyk(cdK.color.rgb).w;

	c = CalculateIntensity(cdC.dist, c);
	m = CalculateIntensity(cdM.dist, m);
	y = CalculateIntensity(cdY.dist, y);
	k = CalculateIntensity(cdK.dist, k);

	return CalculateComposite(CmykToRgb(float4(c, m, y, k)), v_in.uv);
}


float4 mainImage(VertData v_in) : TARGET
{	
	if (HalftoneType == HALFTONE_TYPE_RGB)
		return HalftoneRgb(v_in);
	if (HalftoneType == HALFTONE_TYPE_CMY)
		return HalftoneCmy(v_in);
	if (HalftoneType == HALFTONE_TYPE_CMYK)
		return HalftoneCmyk(v_in);
	return HalftoneLuma(v_in);
}