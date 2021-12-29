// Border shader filter by Surreal_7


uniform float     border_thickness = 16.0;
uniform float     screen_space_border_thickness = 0.0;
uniform float     corner_radius = 8;
uniform float     screen_space_corner_radius = 0.0;
uniform float4    top_left_color = { 0.1, 0.025, 0.0, 1.0 };
uniform float4    top_right_color = { 0.1, 0.025, 0.0, 1.0 };
uniform float4    bottom_left_color = { 0.1, 0.025, 0.0, 1.0 };
uniform float4    bottom_right_color = { 0.1, 0.025, 0.0, 1.0 };
uniform bool      fit_content = true;

float4 mainImage(VertData v_in) : TARGET
{
   float4 color;

   // Ok, so we need to determine if we are currently 
   // drawing the inner part, the border, or outside the border.

   // fold the rectangle over in both directions so we can test just one corner
   // and put the coordinate in homogeneous space
   float2 one = float2(1.0, 1.0);
   float2 edge = (one - abs(v_in.uv * 2.0 - one)) * 0.5;
   // edge.x *= uv_pixel_interval.y / uv_pixel_interval.x; <-- why don't I have to adjust for source aspect ratio??  weird.
   edge /= uv_pixel_interval;
   
   bool isBorder = (edge.x < border_thickness) || (edge.y < border_thickness);
   bool isAlpha = false;
   
   // see if we are in the corner regions
   if ((edge.x < corner_radius) && (edge.y < corner_radius))
   {
      // we're in the radius corner
      float len = length(float2(corner_radius, corner_radius) - edge);
      isBorder = (len > corner_radius - border_thickness);
      isAlpha = (len > corner_radius);
   }   

   
   // float4 screenPos = mul(v_in.pos, ViewProj);
   //isBorder = (screenPos.x < 100);


   if (isAlpha)
   {
      color = float4(0.0, 0.0, 0.0, 0.0);
   }
   else if (isBorder)
   {
      // interpolate the corners
      float4 topColor = lerp(top_left_color, top_right_color, v_in.uv.x);
      float4 bottomColor = lerp(bottom_left_color, bottom_right_color, v_in.uv.x);
      color = lerp(topColor, bottomColor, v_in.uv.y);
   }
   else
   {
      // we're part of the content
      float2 uv = v_in.uv;
      if (fit_content)
      {
         // remap the content range to the inside of the border
         float2 borderUV = uv_pixel_interval * border_thickness;
         float2 range = one - (borderUV * 2.0);
         uv = (uv - borderUV) / range;
      }
      color = image.Sample(textureSampler, uv);
   }

   return color;
}
