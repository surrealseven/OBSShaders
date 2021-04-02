// modulate shader filter by Surreal_7

uniform float     frequency = 0.5;
uniform float     phase = 0.0;
uniform float     envelope_on = 1;
uniform float     envelope_on_to_off = 1;
uniform float     envelope_off = 1;
uniform float     envelope_off_to_on = 1;

uniform float4    off_color = { 0.0, 0.0, 0.0, 1.0 };
uniform float     off_alpha = 0.0;

#define PI 3.14159265359

float4 mainImage(VertData v_in) : TARGET
{
    // get the color in the middle of the screen tile
    float4 color = image.Sample(textureSampler, v_in.uv);

    float4 offColor = off_color;
    offColor.a = off_alpha;


    float totalTime = envelope_on + envelope_on_to_off + envelope_off + envelope_off_to_on;
    float period = frac(elapsed_time * frequency + phase) * totalTime;
    float t;

    if (period < envelope_on)
    {
       t = 1.0;
    }
    else
    {
       period -= envelope_on;
       if (period < envelope_on_to_off)
       {
          t = cos(period / envelope_on_to_off * PI) * 0.5 + 0.5;
       }
       else
       {
          period -= envelope_on_to_off;
          if (period < envelope_off)
          {
             t = 0.0;
          }
          else
          {
             period -= envelope_off;
             t = -cos(period / envelope_off_to_on * PI) * 0.5 + 0.5;
          }
       }
    }

    color = lerp(offColor, color, t);

    return color;
}
