shader_type canvas_item;
uniform sampler2D noise : repeat_enable;
uniform vec2 scroll = vec2(0.005, 0.005);
uniform float noise_scale = 10.0;
void fragment() {
	vec4 text = texture(TEXTURE, UV);
	vec4 noise_updated = texture(noise, UV * noise_scale + scroll * TIME);

	text.a -= text.r;
	text.rgb = noise_updated.rgb;
	COLOR = text;
}
