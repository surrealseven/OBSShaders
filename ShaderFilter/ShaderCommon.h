////////////////////////////////////////////////////////////////////////////////
// Common stuff

#define PI		 3.141592653589
#define TWOPI	 6.283185307179
#define HALFPI  1.570796326794
#define DEG2RAD 0.017453292519
#define RAD2DEG 57.29577951308

#define Remap(destA, destB, srcA, srcB, t)  lerp(destA, destB, (t - srcA) / (srcB - srcA))

////////////////////////////////////////////////////////////////////////////////
// Geometry

float2x2 MakeRotation2D(float angle)
{
	float s, c;
	sincos(angle, s, c);

	return float2x2(c, s, -s, c);
}

////////////////////////////////////////////////////////////////////////////////
// Geometry

bool PointInTriangle(float2 pt, float2 p1, float2 p2, float2 p3)
{
	// compute triangle sides
	float2 v0 = p3 - p1;
	float2 v1 = p2 - p1;
	float2 v2 = pt - p1;

	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);

	// compute barycentric coordinates
	float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	// Check if point is in triangle
	return (u >= 0) && (v >= 0) && (u + v <= 1);
}

bool PointInQuad(float2 pt, float2 p1, float2 p2, float2 p3, float2 p4)
{
	return PointInTriangle(pt, p1, p2, p3) || PointInTriangle(pt, p1, p3, p4);
}

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

////////////////////////////////////////

float3 RgbToYuv(float3 rgb)
{
	float3x3 m = float3x3(
		0.2126, 0.7152, 0.0722,
		-0.1146, -0.3854, 0.5,
		0.5, -0.4542, -0.0458);
	return mul(m, rgb) + float3(0, 0.5, 0.5);
}

float3 YuvToRgb(float3 yuv)
{
	float3x3 m = float3x3(
		1, 0, 1.5748,
		1, -0.1873, -0.4681,
		1, 1.8556, 0);
	return mul(m, yuv - float3(0, 0.5, 0.5));
}

float4 RgbaToYuv(float4 rgba)
{
	float3 yuv = RgbToYuv(rgba.rgb);
	return float4(yuv.x, yuv.y, yuv.z, rgba.a);
}

float4 YuvToRgba(float4 yuv)
{
	float3 rgb = YuvToRgb(yuv);
	return float4(rgb.r, rgb.g, rgb.b, yuv.a);
}

////////////////////////////////////////

float3 RgbToYCbCr(float3 rgb)
{
	float3x3 m = float3x3(
		0.299, 0.587, 0.114,
		-0.169, -0.331, 0.5,
		0.5, -0.419, -0.081);
	return mul(m, rgb) + float3(0, 128.0 / 255.0, 128.0 / 255.0);
}

float3 YCbCrToRgb(float3 yCbCr)
{
	float3x3 m = float3x3(
		1, 0, 1.400,
		1, -0.343, -0.711,
		1, 1.765, 0);
	return mul(m, yCbCr - float3(0, 128.0 / 255.0, 128.0 / 255.0));
}

float4 RgbaToYCbCr(float4 rgba)
{
	float3 yCbCr = RgbToYCbCr(rgba.rgb);
	return float4(yCbCr.x, yCbCr.y, yCbCr.z, rgba.a);
}

float4 YCbCrToRgba(float4 yCbCr)
{
	float3 rgb = YCbCrToRgb(yCbCr.rgb);
	return float4(rgb.r, rgb.g, rgb.b, yCbCr.a);
}

////////////////////////////////////////

float3 RgbToCmy(float3 rgb)
{
	return 1 - rgb;
}

float3 CmyToRgb(float3 cmy)
{
	return 1 - cmy;
}

float4 CmyToCmyk(float3 cmy)
{
	float k = 1.0;
	k = min(k, cmy.x);
	k = min(k, cmy.y);
	k = min(k, cmy.z);
	float4 cmyk;
	if (k > 0.0)
		cmyk.xyz = (cmy - k) / (1.0 - k);
	else
		cmyk.xyz = 0.0;
	cmyk.w = k;
	return cmyk;
}

float3 CmykToCmy(float4 cmyk)
{
	float3 k = cmyk.www;
	return cmyk.xyz * (1 - k) + k;
}

float4 RgbToCmyk(float3 rgb)
{
	return CmyToCmyk(RgbToCmy(rgb));
}

float3 CmykToRgb(float4 cmyk)
{
	return CmyToRgb(CmykToCmy(cmyk));
}

////////////////////////////////////////

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
// default samplers

sampler_state border_texture_sampler
{
	Filter = Linear;
	AddressU = Border;
	AddressV = Border;
	BorderColor = 00000000;
};

sampler_state wrap_texture_sampler
{
	Filter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
	BorderColor = 00000000;
};

sampler_state mirror_texture_sampler
{
	Filter = Linear;
	AddressU = Mirror;
	AddressV = Mirror;
	BorderColor = 00000000;
};

sampler_state clamp_texture_sampler
{
	Filter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
	BorderColor = 00000000;
};

////////////////////////////////////////////////////////////////////////////////
