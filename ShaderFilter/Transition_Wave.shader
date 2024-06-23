#include "TransitionShader.h"


uniform float num_waves <
	string label = "Number of Waves";
	string description = "Number of waves to display simultaneously.";
	string widget_type = "slider";
	float minimum = 1.0;
	float maximum = 20.0;
	float step = 0.1;
> = 7.5;

uniform float amplitude <
	string label = "Amplitude";
	string description = "Size of the waves.";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.07;


uniform float fade_duration <
	string label = "Fade Duration";
	string description = "Percentage of the transition during which the crossfade is applied.";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.4;

uniform float max_wave_duration <
	string label = "Maximum Wave Duration";
	string description = "Percentage of the transition where the wave effect stays at full amplitude.";
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 1.0;
	float step = 0.01;
> = 0.16;

uniform float vertical_climb <
	string label = "Vertical Frequency";
	string description = "Speed at which waves climb the screen vertically.";
	string widget_type = "slider";
	float minimum = -2;
	float maximum = 2;
	float step = 0.01;
> = 0.75;



float4 mainImage(VertData v_in) : TARGET
{
	float time = elapsed_time;
	float y = v_in.uv.y + time * vertical_climb;
	float phase = sin(y * PI * 2 * num_waves);

	float start = 0.5f - max_wave_duration * 0.5f;
	float t = smoothstep(0.0f, start, transition_time) * smoothstep(0.0f, start, 1.0f - transition_time);
	float x = sin(phase) * t * amplitude;

	v_in.uv.x += x;

	float4 sampleA = image_a.Sample(border_texture_sampler, v_in.uv);
	float4 sampleB = image_b.Sample(border_texture_sampler, v_in.uv);

	t = saturate((transition_time - (0.5f - fade_duration * 0.5f)) / fade_duration);
	float4 rgba = lerp(sampleA, sampleB, t);	

	if (convert_linear)
		rgba.rgb = srgb_nonlinear_to_linear(rgba.rgb);
	return rgba;
}