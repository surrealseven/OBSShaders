#include "FilterShader.h"
#include "ShaderCommon.h"



uniform float speed1 <
	string label = "Speed 1";
	string widget_type = "slider";
	float minimum = -2.0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.37;

uniform float speed2 <
	string label = "Speed 2";
	string widget_type = "slider";
	float minimum = -2.0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.92;

uniform float speed3 <
	string label = "Speed 3";
	string widget_type = "slider";
	float minimum = -2.0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.10;

uniform float speed4 <
	string label = "Speed 4";
	string widget_type = "slider";
	float minimum = -2.0;
	float maximum = 2.0;
	float step = 0.01;
> = 0.78;


#define BORDERMODE_NONE		0
#define BORDERMODE_WRAP		1
#define BORDERMODE_CLAMP	2
#define BORDERMODE_MIRROR	3

uniform int texture_border_mode <
	string label = "Texture Border Mode";
	string widget_type = "select";
	int option_0_value = BORDERMODE_NONE;
	string option_0_label = "None";
	int option_1_value = BORDERMODE_WRAP;
	string option_1_label = "Wrap";
	int option_2_value = BORDERMODE_CLAMP;
	string option_2_label = "Clamp";	
	int option_3_value = BORDERMODE_MIRROR;
	string option_3_label = "Mirror";
> = BORDERMODE_MIRROR;





float4 mainImage(VertData v_in) : TARGET
{
	float2 uv = v_in.uv;

	uv.x += 0.1 * sin(6.0 * uv.y + speed1 * elapsed_time);
	uv.y += 0.5 * sin(4.0 * uv.x + speed2 * elapsed_time);
	uv.x += 0.2 * sin(5.0 * uv.y + speed3 * elapsed_time);
	uv.y += 0.3 * sin(3.0 * uv.x + speed4 * elapsed_time);

	float4 color;

    if (texture_border_mode == BORDERMODE_NONE)
		color = image.Sample(border_texture_sampler, uv);
    else if (texture_border_mode == BORDERMODE_WRAP)
		color = image.Sample(wrap_texture_sampler, uv);
    else if (texture_border_mode == BORDERMODE_CLAMP)
		color = image.Sample(clamp_texture_sampler, uv);
    else if (texture_border_mode == BORDERMODE_MIRROR)
        color = image.Sample(mirror_texture_sampler, uv);
    
	
	return color;
}
