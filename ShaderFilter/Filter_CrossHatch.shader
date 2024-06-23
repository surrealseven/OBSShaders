#include "FilterShader.h"
#include "ShaderCommon.h"

uniform float LineSpacing <
	string widget_type = "slider";
	string name = "Line Spacing";
	float minimum = 2;
	float maximum = 100;
	float step = 0.1;
> = 20;

uniform float LineThickness <
	string widget_type = "slider";
	string name = "LIne Thickness";
	float minimum = 0.0;
	float maximum = 50.0;
	float step = 0.1;
> = 5;

uniform float AntiAlias <
	string widget_type = "slider";
	string name = "Antialiasing";
	float minimum = 0.0;
	float maximum = 4.0;
	float step = 0.1;
> = 2.0;

uniform float Rotation <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 360.0;
	float step = 0.1;
> = 0;

uniform float NoiseFrequency <
	string widget_type = "slider";
	string name = "Noise Frequency";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.5;

uniform float NoiseAmplitude <
	string widget_type = "slider";
	string name = "Noise Amplitude";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.5;

uniform float HatchBias <
	string widget_type = "slider";
	string name = "Hatch Bias";
	float minimum = 0.0;
	float maximum = 3.0;
	float step = 0.001;
> = 1;


uniform float Spread <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 5.0;
	float step = 0.1;
> = 1.5;

uniform float LowThreshold <
	string name = "Low Threshold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float HighThreshold <
	string name = "High Threshold";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 1.0;

uniform float EdgeBias <
	string name = "Edge Bias";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 5.0;
	float step = 0.01;
> = 3.0;

uniform float Fade <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.1;

uniform float AlphaFade <
	string name = "Alpha Fade";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;

uniform float Desaturation <
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.0;



float GetHatchLevel(float2 uv, float offset, float rotation, float spacing)
{
	uv = mul(uv, MakeRotation2D(rotation));

	offset += (sin(uv.y * PI * 8.0 * 33.0 * NoiseFrequency) + 
			   sin(uv.x * PI * 8.0 * 37.0 * NoiseFrequency)) * 0.002 * NoiseAmplitude;

	spacing += LineSpacing;
	float cellCount = uv_size.x / spacing;
	
	float x = frac((uv.x + offset) * cellCount);
	x = x * 2.0 - 1.0;

	float antiAlias = uv_pixel_interval.x * AntiAlias * cellCount;
	float range = uv_pixel_interval.x * (float)LineThickness * cellCount * 0.5;
	float t = smoothstep(-range - antiAlias, -range, x) * 1.0 - smoothstep(range, range + antiAlias, x);

	return t;
}



float4 mainImage(VertData v_in) : TARGET
{	
	float2 uv = v_in.uv;
	uv.x *= uv_size.x / uv_size.y;

	float4 realColor = image.Sample(clamp_texture_sampler, v_in.uv);
	float luma = RgbToLuma(realColor.rgb);
	luma = pow(luma, HatchBias);

	float hatch = 0.0;

	luma *= 5;
	if (luma < 4)
		hatch = max(hatch, GetHatchLevel(uv, 0.0, (Rotation + 48.0) * DEG2RAD, 0.0));		
	if (luma < 3)
		hatch = max(hatch, GetHatchLevel(uv, 0.0, (Rotation - 42.0) * DEG2RAD, 1.382));		
	if (luma < 2)
		hatch = max(hatch, GetHatchLevel(uv, 0.3, (Rotation + 94.0) * DEG2RAD, 0.873));
	if (luma < 1)
		hatch = max(hatch, GetHatchLevel(uv, 0.7, (Rotation + 3.0) * DEG2RAD, 1.123));

	hatch = 1.0 - hatch;
	// return float4(t, t, t, 1.0);


	float2 center = v_in.uv;
	float2 range = uv_pixel_interval * Spread;	

	float4 h = image.Sample(clamp_texture_sampler, center + float2(range.x, 0)) -
			   image.Sample(clamp_texture_sampler, center - float2(range.x, 0));
	float4 v = image.Sample(clamp_texture_sampler, center + float2(0, range.y)) -
			   image.Sample(clamp_texture_sampler, center - float2(0, range.y));

	float4 color = 1.0 - max(abs(h), abs(v));

	luma = RgbToLuma(color.rgb);
	luma = smoothstep(LowThreshold, HighThreshold, luma);
	luma = pow(luma, EdgeBias);

	luma = min(luma, hatch);

	float4 saturatedColor = RgbaToHsva(realColor);
	// saturatedColor.y = 1.0;
	saturatedColor.z = 1.0;
	saturatedColor = HsvaToRgba(saturatedColor);
	saturatedColor.rgb *= luma;
	saturatedColor.a = 1.0;

	color = lerp(saturatedColor, luma, Desaturation);	
	color = lerp(color, realColor, Fade);
	color.a = lerp(1, realColor.a, AlphaFade);

	return color;
}