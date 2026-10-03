#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

// ------------------------------------------------------------
// BRIGHT & AIRY PASTEL PALETTE (No heavy blacks)
// ------------------------------------------------------------
const int PALETTE_SIZE = 36;
const vec3 PALETTE[PALETTE_SIZE] = vec3[](
    // --- LIGHT PASTELS (Unchanged, already bright) ---
    vec3(1.000, 0.702, 0.776), // FFB3C6 - Pastel Pink
    vec3(0.627, 0.847, 1.000), // A0D8FF - Sky Blue
    vec3(0.722, 0.949, 0.902), // B8F2E6 - Aqua Mint
    vec3(1.000, 0.839, 0.647), // FFD6A5 - Peach
    vec3(0.804, 0.706, 1.000), // CDB4FF - Lavender
    vec3(1.000, 0.878, 0.400), // FFE066 - Butter Yellow
    vec3(0.867, 0.969, 0.663), // DDF7A9 - Lime Pastel
    vec3(1.000, 0.788, 0.871), // FFC9DE - Rose
    vec3(0.780, 0.941, 1.000), // C7F0FF - Ice Blue
    vec3(0.851, 0.761, 1.000), // D9C2FF - Lilac
    vec3(0.710, 0.918, 0.843), // B5EAD7 - Seafoam
    vec3(1.000, 0.898, 0.706), // FFE5B4 - Apricot

    // --- MID-TONES (Brightened & Softened) ---
    vec3(0.902, 0.761, 0.604), // E6C29A - Soft Sand / Clay
    vec3(0.737, 0.792, 0.651), // BCCAA6 - Soft Olive / Leaves
    vec3(0.831, 0.647, 0.698), // D4A5B2 - Dusty Rose
    vec3(0.722, 0.647, 0.678), // B8A5AD - Soft Mauve
    vec3(0.569, 0.839, 0.733), // 91D6BB - Bright Mint
    vec3(0.659, 0.675, 0.871), // A8ACDE - Periwinkle
    vec3(0.969, 0.663, 0.635), // F7A9A2 - Soft Coral
    vec3(0.949, 0.898, 0.706), // F2E5B4 - Pale Sand
    vec3(0.631, 0.722, 0.612), // A1B89C - Muted Moss
    vec3(0.788, 0.510, 0.463), // C98276 - Soft Rust
    vec3(0.635, 0.722, 0.831), // A2B8D4 - Muted Blue
    vec3(0.788, 0.706, 0.831), // C9B4D4 - Soft Violet

    // --- SHADED TONES (No true blacks, just soft shadows) ---
    vec3(0.557, 0.682, 0.796), // 8EAECB - Slate Blue
    vec3(0.573, 0.533, 0.733), // 9288BB - Soft Violet
    vec3(0.424, 0.478, 0.478), // 6C7A7A - Muted Midnight
    vec3(0.431, 0.431, 0.431), // 6E6E6E - Warm Grey
    vec3(0.478, 0.408, 0.376), // 7A6860 - Muted Brown
    vec3(0.541, 0.596, 0.510), // 8A9882 - Sage
    vec3(0.659, 0.490, 0.490), // A87D7D - Dusty Terracotta
    vec3(0.416, 0.522, 0.620), // 6A859E - Soft Ocean
    vec3(0.533, 0.478, 0.588), // 887A96 - Muted Plum
    vec3(0.620, 0.620, 0.620), // 9E9E9E - Stone
    vec3(0.784, 0.784, 0.784), // C8C8C8 - Light Stone
    vec3(0.949, 0.949, 0.949)  // F2F2F2 - Bright White
);

// Helper function to find the nearest palette color
vec3 snapToPalette(vec3 color) {
    float minDist = 1e10;
    vec3 bestColor = PALETTE[0];

    for (int i = 0; i < PALETTE_SIZE; i++) {
        vec3 diff = color - PALETTE[i];
        float dist = dot(diff, diff);
        
        if (dist < minDist) {
            minDist = dist;
            bestColor = PALETTE[i];
        }
    }
    return bestColor;
}

void main() {
    // 1. Handle transparency
    vec4 origTex = texture(gtexture, texcoord);
    if (origTex.a < alphaTestRef) {
        discard;
    }

    // 2. Get the "primary color"
    vec4 avgColor = textureLod(gtexture, texcoord, 10.0);

    // 3. Snap to palette
    vec3 flatColor = snapToPalette(avgColor.rgb);

    // 4. Apply biome tint and lighting
    color = vec4(flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb, 1.0);
}