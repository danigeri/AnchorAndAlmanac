shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);
uniform float distortion : hint_range(-1,1) = 0.2;
uniform vec4 tone_color : source_color;
uniform vec4 top_color: source_color;
uniform float light_start: hint_range(0.0,1.0) = 0.275;
uniform float light_end: hint_range(0.0,1.0) = 0.4;
uniform vec2 time_slowdown = vec2(2,2);



void fragment() {
	float depth = texture(noise, UV + scroll * TIME / time_slowdown).r
	*  texture(noise2, UV + scroll2 * TIME / time_slowdown).r;
	vec4 noise_col = texture(noise, UV + scroll * TIME);
	vec4 screen_col = texture(SCREEN_TEXTURE,
		SCREEN_UV + distortion * vec2(depth));
	vec4 top_light = smoothstep(light_start, light_end, depth) * top_color;
	COLOR = screen_col * tone_color + top_light;
	COLOR.a = 1.0;
}
