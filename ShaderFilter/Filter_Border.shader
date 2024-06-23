#include "FilterShader.h"
#include "ShaderCommon.h"


uniform float BorderPixels <
	string widget_type = "slider";
	string name = "Border Width";
	float minimum = 0.0;
	float maximum = 150.0;
	float step = 1.0;
> = 16.0;

uniform float4 BorderColor <
	string name = "Border Color";
> = { 1.0, 0.25, 0.0, 1.0 };

uniform bool UseBorderTexture <
	string name = "Use Border Texture";
> = false;

uniform texture2d BorderTexture <
	string name = "Border Texture";
	string widget_type = "input";
	bool automatic = false;
>;

uniform float BorderAlpha <
	string name = "Border Alpha";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 1.0;

uniform float4 BackgroundColor <
	string name = "Background Color";
> = { 0.0, 0.0, 0.0, 0.0 };

uniform float CornerRadius <
	string name = "Corner Radius";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 600.0;
	float step = 1;
> = 50.0;

uniform float HorizontalPadding <
	string name = "Horizontal Padding";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1000.0;
	float step = 1;
> = 0.0;

uniform float VerticalPadding <
	string name = "Vertical Padding";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1000.0;
	float step = 1;
> = 0.0;


uniform bool FitContent <
	string name = "Fit Content";
> = false;

uniform float ContentScale <
	string name = "Content Scale";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 2.0;
	float step = 0.01;
> = 1.0;

float3 CalculateColorContributions(VertData v_in)
{
	float cornerRadius = min(CornerRadius, min(uv_size.x, uv_size.y) * 0.5);

	// fold over the the texture coordinates in both directions so we can do all of
	// the region calculations for a single corner.  this gives us a range of 0 to 1
	// where 0,0 is the rounded corner, and 1,1 is fully within the border.
	float2 uv = 0.5 - abs(v_in.uv - 0.5);

	float2 pos = uv * uv_size;
	// pos.x *= uv_size.x / uv_size.y;  // <-- applying aspect ratio or not seems to be dependent on the type of transform applied to the source

	pos.x -= HorizontalPadding;
	pos.y -= VerticalPadding;	

	// first calculate alpha which will define the outer shape
	float2 radiusCenter = max(pos, cornerRadius);
	float dist = distance(radiusCenter, pos);
	float alpha = smoothstep(dist - 1, dist, cornerRadius);

	// calculate the border that follows the corner radius and the rectangular border.  combine
	// these two to determine what is content and what is border
	float cornerBorder = smoothstep(dist - 1, dist, max(cornerRadius - BorderPixels, 1));
	float innerBorder = (smoothstep(BorderPixels - 1, BorderPixels, pos.x) *
		smoothstep(BorderPixels - 1, BorderPixels, pos.y));
	float contentMultiplier = cornerBorder * innerBorder;
	float borderMultiplier = 1 - contentMultiplier;

	return float3(contentMultiplier, borderMultiplier, alpha);
}

float2 CalculateSourceCoordinates(VertData v_in)
{
	float2 uv = v_in.uv;

	float scale = 1 / ContentScale;

	if (FitContent)
	{
		scale *= min(uv_size.x / (uv_size.x - (BorderPixels + HorizontalPadding) * 2), 
				     uv_size.y / (uv_size.y - (BorderPixels + VerticalPadding) * 2));		
	}

	uv = (uv - 0.5) * scale + 0.5;

	return uv;
}


float4 mainImage(VertData v_in) : TARGET
{	
	float3 contributions = CalculateColorContributions(v_in);

	float4 borderColor;
	if (UseBorderTexture)
		borderColor = BorderTexture.Sample(clamp_texture_sampler, v_in.uv) * contributions.y;
	else	
		borderColor = BorderColor * contributions.y;
	borderColor.a *= BorderAlpha;

	float4 color = image.Sample(clamp_texture_sampler, CalculateSourceCoordinates(v_in));
	float4 bgColor = BackgroundColor;
	color = lerp(bgColor, color, color.a) * contributions.x;
	color = color + borderColor;

	color.a *= contributions.z;

	return color;
}