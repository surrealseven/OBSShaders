﻿#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float Strength <
	string name = "Strength";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Curvature <
	string name = "Curvature";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = -0.75;
	float maximum = 1;
> = 0.5;

uniform float Fade <
	string name = "Fade";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.1;

uniform float Desaturation <
	string name = "Desaturation";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.0;

uniform float ChromaDistortion <
	string name = "Chroma Distortion";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0.0;

uniform float4 BorderColor <
	string name = "Border Color";
> = { 0.0, 0.0, 0.0, 1.0 };

uniform float2 OffsetR <
	string name = "R Offset";
	string widget_type = "slider";
	float2 minimum = { -1.0, -1.0 };
	float2 maximum = { 1.0, 1.0 };
	float2 step = { 0.01, 0.01 };
> = { 0.0, 0.0 };

uniform float2 OffsetG <
	string name = "G Offset";
	string widget_type = "slider";
	float2 minimum = { -1.0, -1.0 };
	float2 maximum = { 1.0, 1.0 };
	float2 step = { 0.01, 0.01 };
> = { 0.0, 0.0 };

uniform float2 OffsetB <
	string name = "B Offset";
	string widget_type = "slider";
	float2 minimum = { -1.0, -1.0 };
	float2 maximum = { 1.0, 1.0 };
	float2 step = { 0.01, 0.01 };
> = { 0.0, 0.0 };

uniform float2 OffsetU <
	string name = "U Offset";
	string widget_type = "slider";
	float2 minimum = { -1.0, -1.0 };
	float2 maximum = { 1.0, 1.0 };
	float2 step = { 0.01, 0.01 };
> = { 0.0, 0.0 };

uniform float2 OffsetV <
	string name = "V Offset";
	string widget_type = "slider";
	float2 minimum = { -1.0, -1.0 };
	float2 maximum = { 1.0, 1.0 };
	float2 step = { 0.01, 0.01 };
> = { 0.0, 0.0 };

uniform float ChromaticDistort <
	string name = "Chromatic Aberration";
	string widget_type = "slider";
	float minimum = -1.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float ScanlineCount <
	string name = "Scanline Count";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 500.0;
	float step = 1;
> = 0.0;

uniform float ScanlineMoire <
	string name = "Scanline Moire";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float Flicker <
	string name = "Flicker";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float HorizontalHold <
	string name = "Horizontal Hold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float VerticalHold <
	string name = "Vertical Hold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float RollBarSpeed <
	string name = "Roll Bar Speed";
	string widget_type = "slider";
	float minimum = -2.0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.2;

uniform float RollBarDepth <
	string name = "Roll Bar Depth";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;


float4 FetchDistortedColor(float2 uv, float2 offset, float scale, float dist)
{
	float2 center = float2(0.5, 0.5);
	uv = uv - center;
	uv += offset * 0.01 * Strength;
	uv += uv * dist * (ChromaticDistort * scale) * Strength;
	uv = uv + center;

	float4 yColor = RgbaToYuv(image.Sample(clamp_texture_sampler, uv));
	float4 uColor = RgbaToYuv(image.Sample(clamp_texture_sampler, uv + OffsetU * 0.01 * Strength));
	float4 vColor = RgbaToYuv(image.Sample(clamp_texture_sampler, uv + OffsetV * 0.01 * Strength));
	return YuvToRgba(float4(yColor.x, uColor.y, vColor.z, yColor.a));
}


float4 mainImage(VertData v_in) : TARGET
{	
	// shape the screen	
	float2 uv = v_in.uv;
	float2 normUv = uv - float2(0.5, 0.5);
	float dist = length(normUv) * Curvature * Strength;
	uv = uv + normUv * (dist * dist) * sign(dist);

	// add horizontal and vertical hold noise
	uv.x += sin((uv.y +  rand_f) * PI * 2 * rand_f) * rand_f * HorizontalHold * 0.01 * Strength;
	uv.y += rand_f * VerticalHold * 0.01 * Strength;

	// apply color distortion
	float4 colorR = FetchDistortedColor(uv, OffsetR, 0.2, dist);
	float4 colorG = FetchDistortedColor(uv, OffsetG, 0.0, dist);
	float4 colorB = FetchDistortedColor(uv, OffsetB, -0.2, dist);
	float4 colorA = image.Sample(clamp_texture_sampler, uv);

	float4 color = float4(colorR.r, colorG.g, colorB.b, colorA.a);

	// desaturate the color
	color = DesaturateRgba(color, Desaturation * Strength);

	// apply scan line effect, flicker, and roll bar
	color.rgb *= saturate((1 + ScanlineMoire * 0.8) - sin(PI * 2 * uv.y * ScanlineCount) * (ScanlineMoire * 0.9 + 0.1) * Strength);
	color.rgb *= 1.0 - (rand_f * Flicker * 0.5 * Strength);
	color.rgb *= saturate((1 + (1 - RollBarDepth) * 0.5) - sin(PI * 2 * (uv.y - elapsed_time * RollBarSpeed)) * 0.5 * Strength);

	// anti-alias the border and give the image a vingnette
	float fade = Fade * 0.1 * Strength;
	float2 t2 = smoothstep(0, fade, uv) * smoothstep(0, fade, 1.0 - uv);
	float t = t2.x * t2.y;
	color = lerp(BorderColor, color, t);
	
	return color;
}