#include "FilterShader.h"
#include "ShaderCommon.h"

#define PROGRESS_TYPE_SWIPEX	0
#define PROGRESS_TYPE_SWIPEY	1
#define PROGRESS_TYPE_SLIDEX	2
#define PROGRESS_TYPE_SLIDEY	3
#define PROGRESS_TYPE_STRETCHX	4
#define PROGRESS_TYPE_STRETCHY	5

uniform int ProgressType <
  string label = "Progress Type";
  string widget_type = "select";
  int    option_0_value = PROGRESS_TYPE_SWIPEX;
  string option_0_label = "Swipe X";
  int    option_1_value = PROGRESS_TYPE_SWIPEY;
  string option_1_label = "Swipe Y";
  int    option_2_value = PROGRESS_TYPE_SLIDEX;
  string option_2_label = "Slide X";
  int    option_3_value = PROGRESS_TYPE_SLIDEY;
  string option_3_label = "Slide Y";
> = PROGRESS_TYPE_SWIPEX;

uniform float Progress <
	string name = "Progress";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 1;

uniform float Smooth <
	string name = "Smoothing";
	string widget_type = "slider";
	float step = 0.01;
	float minimum = 0;
	float maximum = 1;
> = 0;

uniform bool Reverse <
> = false;

uniform float4 BackgroundColor <
	string name = "Background Color";
> = { 0.0, 0.0, 0.0, 0.0 };




float4 CalculateColor(float2 uv, float progress)
{
	if (Reverse)
		progress = 1.0 - progress;
	float4 color = image.Sample(clamp_texture_sampler, uv);
	float p = lerp(Smooth * 0.125, 1 - Smooth * 0.125, progress);
	float t = smoothstep(Progress - Smooth * 0.125, Progress + Smooth * 0.125, p);
	color = lerp(color, BackgroundColor, t);
	return color;
}


float4 ProgressSwipeX(VertData v_in) : TARGET
{
	return CalculateColor(v_in.uv, v_in.uv.x);
}

float4 ProgressSwipeY(VertData v_in) : TARGET
{
	return CalculateColor(v_in.uv, 1.0 - v_in.uv.y);
}

float4 ProgressSlideX(VertData v_in) : TARGET
{
	float2 uv = v_in.uv;
	uv.x += (Reverse) ? Progress - 1 : 1 - Progress;
	return CalculateColor(uv, v_in.uv.x);
}

float4 ProgressSlideY(VertData v_in) : TARGET
{
	float2 uv = v_in.uv;
	uv.y += (Reverse) ? 1 - Progress : Progress - 1;
	return CalculateColor(uv, 1 - v_in.uv.y);
}


float4 mainImage(VertData v_in) : TARGET
{	
	if (ProgressType == PROGRESS_TYPE_SLIDEX)
		return ProgressSlideX(v_in);
	if (ProgressType == PROGRESS_TYPE_SLIDEY)
		return ProgressSlideY(v_in);
	if (ProgressType == PROGRESS_TYPE_SWIPEY)
		return ProgressSwipeY(v_in);
	return ProgressSwipeX(v_in);
}