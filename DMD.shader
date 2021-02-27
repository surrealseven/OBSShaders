// DMD shader filter by Surreal_7

uniform float     led_size = 16.0;
uniform float     led_fatness = 1.0;
uniform int       intensity_steps = 3;
uniform float     brightness = 1.0;
uniform float     contrast = 1.0;
uniform float     fade = 1.0;
uniform bool      monochrome = true;
uniform bool      smooth = false;

uniform float4    unlit_color = { 0.1, 0.025, 0.0, 1.0 };
uniform float4    lit_color = { 1.0, 0.25, 0.0, 1.0 };
uniform float4    background_color = { 0.0, 0.0, 0.0, 1.0 };
uniform float     background_opacity = 1.0;


float4 mainImage(VertData v_in) : TARGET
{
    float2 ledUV = uv_pixel_interval * led_size;
    float2 pix = v_in.uv;
    float2 tileCorner = floor(pix / ledUV) * ledUV;
    float2 tileCenter = tileCorner + ledUV * 0.5;

    // get the color in the middle of the screen tile
    float4 color = image.Sample(textureSampler, tileCenter);

    if (smooth)
    {
       float2 sampleOffset = ledUV * 0.25;
       color += image.Sample(textureSampler, tileCenter + sampleOffset);
       color += image.Sample(textureSampler, tileCenter - sampleOffset);
       sampleOffset.x *= -1;
       color += image.Sample(textureSampler, tileCenter + sampleOffset);
       color += image.Sample(textureSampler, tileCenter - sampleOffset);
       color /= 5;
    }


    // calculate luminance and apply shaping
    if (monochrome)
    {
       float gray = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
       gray *= brightness;
       gray = (gray - 0.5) * contrast + 0.5;

       gray = round(gray * intensity_steps) / intensity_steps;
       gray = clamp(gray, 0.0, 1.0);
       color.xyz = lerp(unlit_color, lit_color, gray);
    }
    else
    {
       float3 oneHalf = { 0.5, 0.5, 0.5 };
       color.xyz *= brightness;
       color.xyz = (color.xyz - oneHalf) * contrast + oneHalf;
       color.xyz = floor(color.xyz * intensity_steps) / intensity_steps;
    }

    float dist = length((v_in.uv - tileCenter) / ledUV) * 2.0;
    dist = pow(dist, led_fatness);
    color.a = 1.0;
    float4 bgColor = background_color;
    bgColor.a = background_opacity;
    color = lerp(color, bgColor, dist);

    if (fade < 1.0)
    {
       float4 srcColor = image.Sample(textureSampler, v_in.uv);
       color = lerp(srcColor, color, fade);
    }

    return color;
}
