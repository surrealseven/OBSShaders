// blink shader filter by Surreal_7

uniform float     frequency = 0.5;
uniform float     amplitude = 1;

uniform float4    off_color = { 0.0, 0.0, 0.0, 1.0 };
uniform float     off_alpha = 0.0;

float4 mainImage(VertData v_in) : TARGET
{
    // get the color in the middle of the screen tile
    float4 color = image.Sample(textureSampler, v_in.uv);

    float4 offColor = off_color;
    offColor.a = off_alpha;

    float t = sin(elapsed_time * 3.1415 * 2.0 * frequency) * amplitude * 0.5 + 0.5;
    t = clamp(t, 0.0, 1.0);
    color = lerp(offColor, color, t);

    return color;
}
