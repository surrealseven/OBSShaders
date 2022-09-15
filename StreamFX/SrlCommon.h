
////////////////////////////////////////////////////////////////////////////////
// Common stuff

#define PI		3.14159265359

////////////////////////////////////////////////////////////////////////////////
// Color stuff

float RgbToLuma(float3 color)
{
	float3 scale = float3(0.3, 0.59, 0.11);
	return dot(color, scale);
}

float3 DesaturateRgb(float3 rgb, float strength)
{
	float luma = RgbToLuma(rgb);
	float3 gray = float3(luma, luma, luma);
	return lerp(rgb, gray, strength);
}

float4 DesaturateRgba(float4 rgba, float strength)
{
	return float4(DesaturateRgb(rgba.rgb, strength), rgba.a);
}



// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
float3 RgbToHsv(float3 rgb) 
{
	float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = lerp(float4(rgb.bg, K.wz), float4(rgb.gb, K.xy), step(rgb.b, rgb.g));
	float4 q = lerp(float4(p.xyw, rgb.r), float4(rgb.r, p.yzx), step(p.x, rgb.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
float4 RgbaToHsva(float4 rgba) 
{
	return float4(RgbToHsv(rgba.rgb), rgba.a);
}

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
float3 HsvToRgb(float3 hsv) 
{
	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
}

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
float4 HsvaToRgba(float4 hsva) 
{
	return float4(HsvToRgb(hsva.rgb), hsva.a);
}

////////////////////////////////////////////////////////////////////////////////
