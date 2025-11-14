shader_type canvas_item;
uniform sampler2D noise : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec4 n = texture(noise, UV + scroll * TIME / vec2(5));
	
	t.a -= t.r;
	t.rgb = n.rgb;
	COLOR = t;
}
