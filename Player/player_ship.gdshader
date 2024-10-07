shader_type canvas_item;

uniform float tint_strength: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Get the original texture color
    vec4 tex_color = texture(TEXTURE, UV);

    // Blend the texture color with white, based on the tint_strength
    COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), tint_strength);
}
