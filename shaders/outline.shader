shader_type canvas_item;
render_mode unshaded;
 
uniform float width : hint_range(0.0, 16.0);
uniform vec4 outline_color : hint_color;
const float lod = .6;
//uniform sampler2D noise;
 
void fragment()
{
    vec2 size = vec2(width) / vec2(textureSize(TEXTURE, 0));
	vec2 edge = UV - vec2(.5);
   
    vec4 sprite_color = texture(TEXTURE, UV);
   
    float alpha = sprite_color.a;
	if (alpha <= 0.5){
		alpha += textureLod(TEXTURE, UV + vec2(0.0, -size.y), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(size.x, -size.y), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(size.x, 0.0), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(size.x, size.y), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(0.0, size.y), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(-size.x, size.y), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(-size.x, 0.0), lod).a;
		alpha += textureLod(TEXTURE, UV + vec2(-size.x, -size.y), lod).a;
		alpha = min(alpha, 1.0);
//		alpha -= abs(edge.x) * size.x * 100.0;
//		alpha -= abs(edge.y) * size.y * 25.0;
//		alpha -= min(texture(noise, UV).r, .5);
		alpha -= sin(TIME * 2.0)* .2 + .5;
	}
	
	vec3 final_color = mix(outline_color.rgb, sprite_color.rgb, sprite_color.a);
	COLOR = vec4(final_color, clamp(alpha, 0.0, 1.0));
	
}