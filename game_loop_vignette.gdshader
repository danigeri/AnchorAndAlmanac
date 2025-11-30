shader_type canvas_item;
render_mode blend_mix;

// --- SHAKE UNIFORMS (New) ---
uniform float ShakeStrength = 0; // 0.0 to 1.0 (Controlled by GDScript)
uniform vec2 FactorA  = vec2(100.0, 100.0); // Shake speed/frequency
uniform vec2 FactorB  = vec2(1.0, 1.0); // Random offset for starting point
uniform vec2 magnitude = vec2(0.015, 0.015); // Max pixel displacement (0.01 = 1% of screen size)

// --- VIGNETTE UNIFORMS (Existing) ---
uniform float intensity : hint_range(0.0, 2.0) = 1.2;
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.01, 1.0) = 0.45;
uniform vec3 vignette_color : source_color = vec3(0.25, 0.18, 0.12);

// This uniform samples the texture of everything rendered *before* this node in the CanvasLayer
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    
    // --- SHAKE CALCULATION ---
    
    // 1. Calculate the shake offset vector (dt) based on real TIME
    // TIME is a built-in Godot uniform that continues to tick even when 'get_tree().paused' is true.
    vec2 dt = vec2(0.0, 0.0);
    dt.x = sin(TIME * FactorA.x + FactorB.x) * magnitude.x;
    dt.y = cos(TIME * FactorA.y + FactorB.y) * magnitude.y;
    
    // 2. Apply the Shake: Calculate the final UV coordinates.
    vec2 final_uv = SCREEN_UV + (dt * ShakeStrength);

    // 3. Get the current pixel's color from the rendered scene using the shaken UV.
    vec4 base_color = texture(SCREEN_TEXTURE, final_uv);

    // --- VIGNETTE CALCULATION (Your existing logic starts here) ---

    // 4. Convert UV from [0, 1] to [-1, 1] for centered calculations.
    vec2 uv = UV * 2.0 - 1.0;

    // 5. Calculate distance from the center (0, 0).
    float dist = length(uv);

    // 6. Calculate the vignette factor using smoothstep.
    float vignette_factor = smoothstep(radius, radius + softness, dist);

    // 7. Apply the darkening/coloring effect to the *already shaken* base_color.
    float darkness = 1.0 - (vignette_factor * intensity);

    // B. Final Color Calculation:
    vec3 final_rgb = base_color.rgb * darkness;

    // Apply warm tint
    final_rgb = mix(final_rgb, vignette_color, vignette_factor * intensity * 0.8);

    // Set the final color.
    COLOR = vec4(final_rgb, base_color.a);
}