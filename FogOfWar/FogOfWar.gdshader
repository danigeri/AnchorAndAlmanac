shader_type canvas_item;
uniform sampler2D noise : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);

void fragment() {
	vec4 text = texture(TEXTURE, UV);
	vec4 noise_updated = texture(noise, UV + scroll * TIME / vec2(5));

	text.a -= text.r;
	text.rgb = noise_updated.rgb;
	COLOR = text;
}
