// DMD shader filter by Surreal_7

uniform float intensity = 0.0;


float4 mainImage(VertData v_in) : TARGET
{
   float PI = 3.14159265359;
   float2 uv = v_in.uv;


   float2 fromCenter = uv - float2(0.5, 0.5);
   float distFromCenter = length(fromCenter);

   float distortion = pow(sin(distFromCenter * PI * 0.5), 1 + intensity * 0.001);
   uv = float2(0.5, 0.5) + fromCenter / distFromCenter * distortion;
   
   float4 srcColor = image.Sample(textureSampler, uv);
   float4 color = srcColor;


   return color;
}
