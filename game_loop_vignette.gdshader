shader_type canvas_item;
render_mode blend_mix;

// --- SHAKE UNIFORMS ---
uniform float ShakeStrength = 0.0;
uniform vec2 FactorA = vec2(100.0, 100.0);
uniform vec2 FactorB = vec2(1.0, 1.0);
uniform vec2 magnitude = vec2(0.015, 0.015);

// --- VIGNETTE UNIFORMS ---
uniform float intensity : hint_range(0.0, 2.0) = 1.2;
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.01, 1.0) = 0.45;
uniform vec3 vignette_color : source_color = vec3(0.25, 0.18, 0.12);

// --- STORM UNIFORMS ---
uniform float storm_mode : hint_range(0.0, 1.0) = 0.0;
uniform float storm_darkness : hint_range(0.0, 1.0) = 0.5;
uniform vec3 storm_color : source_color = vec3(0.15, 0.18, 0.22);
uniform float lightning_frequency : hint_range(0.0, 10.0) = 2.0;
uniform float lightning_intensity : hint_range(0.0, 5.0) = 3.0;
uniform float lightning_speed : hint_range(0.0, 20.0) = 8.0;

// NEW: Configurable storm shake
uniform float storm_shake_amount : hint_range(0.0, 1.0) = 0.0; // 0 = no shake, adjust in inspector
uniform float storm_shake_speed : hint_range(0.0, 10.0) = 0.5; // How fast the ambient shake moves

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Simple hash function for pseudo-random values
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Generate lightning flash value
float get_lightning(float time) {
    float cycle_time = time * lightning_speed;
    float cycle = floor(cycle_time);
    float t = fract(cycle_time);
    
    float rand = hash(cycle * 12.9898);
    
    if (rand < lightning_frequency * 0.1) {
        float flash = 0.0;
        
        if (t < 0.05) {
            flash = smoothstep(0.0, 0.02, t) * smoothstep(0.05, 0.03, t);
        } else if (t < 0.15 && hash(cycle * 7.233) > 0.5) {
            float t2 = (t - 0.05) / 0.1;
            flash = smoothstep(0.0, 0.3, t2) * smoothstep(1.0, 0.5, t2) * 0.6;
        }
        
        return flash * lightning_intensity;
    }
    
    return 0.0;
}

void fragment() {
    // --- SHAKE CALCULATION ---
    vec2 dt = vec2(0.0, 0.0);
    dt.x = sin(TIME * FactorA.x + FactorB.x) * magnitude.x;
    dt.y = cos(TIME * FactorA.y + FactorB.y) * magnitude.y;
    
    // Add configurable ambient storm shake (wave-like motion)
    float ambient_shake = 0.0;
    if (storm_shake_amount > 0.0) {
        ambient_shake = sin(TIME * storm_shake_speed) * storm_shake_amount * storm_mode;
    }
    
    float total_shake = ShakeStrength + ambient_shake;
    vec2 final_uv = SCREEN_UV + (dt * total_shake);
    
    vec4 base_color = texture(SCREEN_TEXTURE, final_uv);
    
    // --- VIGNETTE CALCULATION ---
    vec2 uv = UV * 2.0 - 1.0;
    float dist = length(uv);
    float vignette_factor = smoothstep(radius, radius + softness, dist);
    
    float darkness = 1.0 - (vignette_factor * intensity);
    vec3 final_rgb = base_color.rgb * darkness;
    final_rgb = mix(final_rgb, vignette_color, vignette_factor * intensity * 0.8);
    
    // --- STORM EFFECTS ---
    if (storm_mode > 0.0) {
        // 1. Darken the scene with storm color
        final_rgb = mix(final_rgb, final_rgb * storm_color, storm_mode * storm_darkness);
        
        // 2. Add stronger vignette during storm
        float storm_vignette = vignette_factor * storm_mode * 0.4;
        final_rgb = mix(final_rgb, storm_color * 0.3, storm_vignette);
        
        // 3. Lightning flashes
        float lightning = get_lightning(TIME);
        final_rgb += vec3(lightning * storm_mode);
        
        // Add slight blue tint to lightning
        final_rgb += vec3(lightning * 0.3, lightning * 0.4, lightning * 0.6) * storm_mode;
    }
    
    COLOR = vec4(final_rgb, base_color.a);
}