shader_type canvas_item;
render_mode blend_mix; // Use standard blending

// Uniforms for customization
// Increased default intensity and hint range for a darker effect.
uniform float intensity : hint_range(0.0, 2.0) = 1.2;
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.01, 1.0) = 0.45;
uniform vec3 vignette_color : source_color = vec3(0.25, 0.18, 0.12); // Warm brown/sepia tone

// This uniform samples the texture of everything rendered *before* this node in the CanvasLayer
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    // 1. Get the current pixel's color from the rendered scene below this layer/object.
    vec4 base_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // 2. Convert UV from [0, 1] to [-1, 1] for centered calculations.
    vec2 uv = UV * 2.0 - 1.0;

    // 3. Calculate distance from the center (0, 0).
    float dist = length(uv);

    // 4. Calculate the vignette factor using smoothstep.
    // Here, dist > radius results in a value > 0, increasing the darkening effect.
    float vignette_factor = smoothstep(radius, radius + softness, dist);

    // 5. Apply the darkening/coloring effect.

    // A. Darkening:
    // When intensity is > 1.0, darkness can become negative, which will clamp to 0.0,
    // making the outer edges completely black/vignette_color.
    float darkness = 1.0 - (vignette_factor * intensity);

    // B. Final Color Calculation:
    // Multiply the base color by the darkness factor.
    vec3 final_rgb = base_color.rgb * darkness;

    // Optional: Add the tint color to the final color for a warmer look.
    // Increased the multiplier from 0.5 to 0.8 to make the tinting more prominent.
    final_rgb = mix(final_rgb, vignette_color, vignette_factor * intensity * 0.8);

    // Set the final color. We preserve the original alpha.
    COLOR = vec4(final_rgb, base_color.a);
}