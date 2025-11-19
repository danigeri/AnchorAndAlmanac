shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform float radius = 0.005;
uniform float speed = 1.0;

void fragment() {
    vec4 text = texture(TEXTURE, UV);
    
    vec2 circular_offset = vec2(
        cos(TIME * speed),
        sin(TIME * speed)
    ) * radius;
    
    vec4 noise_updated = texture(noise, UV + circular_offset);
    
    text.a -= text.r;
    text.rgb = noise_updated.rgb;
    COLOR = text;
}