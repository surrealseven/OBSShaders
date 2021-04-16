// scroll shader filter by Surreal_7

uniform float     speed = 16.0;
uniform float     x_scale = 1.0;
uniform float     y_scale = 0.0;
uniform float     x_step = 16.0;
uniform float     y_step = 16.0;


float4 mainImage(VertData v_in) : TARGET
{
   float2 scale = float2(x_scale, y_scale);
   float2 step = float2(x_step, y_step);

   float2 offset = trunc(elapsed_time * speed * scale / step) * step;

   float2 uv = frac(v_in.uv + offset * uv_pixel_interval);

   float4 color = image.Sample(textureSampler, uv);

   return color;
}
