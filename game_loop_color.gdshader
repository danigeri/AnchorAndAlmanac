shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ---- MAIN CONTROLS ----
uniform float warmth : hint_range(0.0, 1.0) = 0.55;         // sepia intensity
uniform float desaturation : hint_range(0.0, 1.0) = 0.30;   // reduces color vibrancy
uniform float contrast : hint_range(-1.0, 1.0) = 0.15;      // subtle contrast boost
uniform float brightness : hint_range(-1.0, 1.0) = 0.05;    // slight lift

// ---- ADVANCED PAPER LOOK ----
uniform float paper_fade : hint_range(0.0, 1.0) = 0.35;     // soft warm overlay
uniform vec3 paper_color : source_color = vec3(0.87, 0.76, 0.58); // parchment base tone

void fragment() {
    // Get the underlying screen pixel
    vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 col = base.rgb;

    // --- 1. Desaturate ---
    float gray = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(col, vec3(gray), desaturation);

    // --- 2. Sepia / Warmth ---
    // classic sepia transform
    vec3 sepia = vec3(
        col.r * 0.393 + col.g * 0.769 + col.b * 0.189,
        col.r * 0.349 + col.g * 0.686 + col.b * 0.168,
        col.r * 0.272 + col.g * 0.534 + col.b * 0.131
    );
    col = mix(col, sepia, warmth);

    // --- 3. Add subtle paper tint ---
    col = mix(col, paper_color, paper_fade);

    // --- 4. Apply contrast ---
    col = (col - 0.5) * (1.0 + contrast) + 0.5;

    // --- 5. Apply brightness ---
    col += brightness;

    // Final output
    COLOR = vec4(col, base.a);
}
