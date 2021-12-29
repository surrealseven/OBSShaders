// scroll shader filter by Surreal_7

uniform float4    key_color = { 0.0, 1.0, 0.0, 1.0 };
uniform float     degree_spread = 20.0;
uniform float     min_saturation = 0.0;
uniform float     max_saturation = 1.0;
uniform float     min_value = 0.0;
uniform float     max_value = 1.0;

float4 ToHsv(float4 color)
{
   float4 hsv = color;

   float cMax, cMin;

   if ((color.r == color.g) && (color.r == color.b))
   {
      hsv.x = 0;
   }
   else if ((color.r > color.g) && (color.r > color.b))
   {
      cMax = color.r;
      cMin = min(color.g, color.b);
      hsv.x = fmod((color.g - color.b) / (cMax - cMin), 6.0) * 60.0;
   }
   else if (color.g > color.b)
   {
      cMax = color.g;
      cMin = min(color.r, color.b);
      hsv.x = ((color.b - color.r) / (cMax - cMin) + 2.0) * 60.0;      
   }
   else
   {
      cMax = color.b;
      cMin = min(color.r, color.g);
      hsv.x = ((color.r - color.g) / (cMax - cMin) + 4.0) * 60.0;
   }

   if (cMax > 0.0)
      hsv.y = (cMax - cMin) / cMax;
   else
      hsv.y = 0;

   hsv.z = cMax;
   hsv.w = color.a;

   return hsv;
}

float4 mainImage(VertData v_in) : TARGET
{   
   float4 color = image.Sample(textureSampler, v_in.uv);

   float4 keyHsv = ToHsv(key_color);
   float4 pixelHsv = ToHsv(color);

   if (abs(keyHsv.x - pixelHsv.x) > degree_spread)
      return color;
   if ((pixelHsv.y < min_saturation) || (pixelHsv.y > max_saturation))
      return color;
   if ((pixelHsv.z < min_value) || (pixelHsv.z > max_value))
      return color;

   return float4(0.0, 0.0, 0.0, 0.0);
}
