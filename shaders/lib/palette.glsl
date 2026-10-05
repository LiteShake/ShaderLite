#ifndef PALETTE_GLSL
#define PALETTE_GLSL

// Single place for the palette option so every shader (terrain, water...) agrees
#define PALETTE 0 // Color palette: 0 = Pastel, 1 = Normal, 2 = Grayscale, 3 = Material White, 4 = Blueprint [0 1 2 3 4]

// ============================================================
// PASTEL PALETTE (Ultra Sketchup)
// ============================================================
const int PASTEL_SIZE = 37;
const vec3 PASTEL[PASTEL_SIZE] = vec3[](
    // --- LIGHT PASTELS ---
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

    // --- MID-TONES ---
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

    // --- SHADED TONES ---
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
    vec3(0.949, 0.949, 0.949), // F2F2F2 - Bright White
    
    // --- DARK TONES (Added back for Deepslate!) ---
    vec3(0.220, 0.240, 0.260)  // 38403D - Muted Deepslate Gray
);

// ============================================================
// NORMAL PALETTE (Vanilla-esque)
// ============================================================
const int NORMAL_SIZE = 16;
const vec3 NORMAL[NORMAL_SIZE] = vec3[](
    vec3(0.15, 0.15, 0.15), // Deepslate
    vec3(0.35, 0.35, 0.35), // Stone
    vec3(0.45, 0.33, 0.22), // Dirt
    vec3(0.35, 0.55, 0.22), // Grass
    vec3(0.20, 0.40, 0.15), // Leaves
    vec3(0.55, 0.42, 0.25), // Wood
    vec3(0.85, 0.80, 0.60), // Sand
    vec3(0.18, 0.35, 0.60), // Water
    vec3(0.30, 0.80, 0.80), // Diamond
    vec3(0.65, 0.15, 0.15), // Redstone
    vec3(0.75, 0.75, 0.75), // Iron
    vec3(0.10, 0.10, 0.10), // Coal
    vec3(0.60, 0.60, 0.60), // Gravel
    vec3(0.90, 0.90, 0.90), // White Wool
    vec3(0.80, 0.60, 0.20), // Gold
    vec3(0.40, 0.20, 0.60)  // Amethyst
);

// ============================================================
// BLUEPRINT PALETTE (navy -> pale cyan, picked by brightness)
// ============================================================
const int BLUEPRINT_SIZE = 6;
const vec3 BLUEPRINT[BLUEPRINT_SIZE] = vec3[](
    vec3(0.040, 0.100, 0.240), // 0A1A3D - Deep Navy
    vec3(0.070, 0.180, 0.400), // 122E66 - Navy
    vec3(0.120, 0.300, 0.580), // 1F4D94 - Blueprint Blue
    vec3(0.250, 0.480, 0.780), // 407AC7 - Mid Blue
    vec3(0.550, 0.740, 0.950), // 8CBDF2 - Light Blue
    vec3(0.880, 0.950, 1.000)  // E0F2FF - Pale Cyan White
);

// Line color for outlines/grid that stays readable on the active palette
vec3 paletteLineColor() {
    #if PALETTE == 4
        return vec3(0.85, 0.93, 1.0);  // white-cyan lines on blue paper
    #else
        return vec3(0.10);
    #endif
}

// ============================================================
// BIOME TINT
// Grass, leaves, vines and water get a green/blue vertex tint. That tint would
// push the monochrome palettes (Grayscale, Material White, Blueprint) back to
// green, so for those we only keep its brightness.
// ============================================================
vec3 applyVertexTint(vec3 flatColor, vec3 vertexColor) {
    #if PALETTE >= 2
        float l = dot(vertexColor, vec3(0.2126, 0.7152, 0.0722));
        return flatColor * mix(1.0, l, 0.7);
    #else
        return flatColor * vertexColor;
    #endif
}

// ============================================================
// SNAP FUNCTION
// ============================================================
float paletteLuma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec3 snapToPalette(vec3 color) {
    #if PALETTE == 2
        // GRAYSCALE: 8 evenly spaced grays from 0.12 to 0.96
        float l = paletteLuma(color);
        float idx = clamp(floor((l - 0.12) / 0.12 + 0.5), 0.0, 7.0);
        return vec3(0.12 + idx * 0.12);

    #elif PALETTE == 4
        // BLUEPRINT: 6 blues chosen by brightness
        float l = paletteLuma(color);
        int idx = int(clamp(floor(l * 6.0), 0.0, 5.0));
        return BLUEPRINT[idx];

    #elif PALETTE == 3
        // MATERIAL WHITE: clay-render look, 5 soft white steps with a faint warm tint
        float l = paletteLuma(color);
        float idx = clamp(floor(l * 5.0), 0.0, 4.0);
        float v = mix(0.72, 0.97, idx / 4.0);
        return vec3(v, v * 0.995, v * 0.985);

    #else
        float minDist = 1e10;
        vec3 bestColor = vec3(0.0);
        #if PALETTE == 1
            bestColor = NORMAL[0];
            for (int i = 0; i < NORMAL_SIZE; i++) {
                vec3 diff = color - NORMAL[i];
                float dist = dot(diff, diff);
                if (dist < minDist) { minDist = dist; bestColor = NORMAL[i]; }
            }
        #else
            bestColor = PASTEL[0];
            for (int i = 0; i < PASTEL_SIZE; i++) {
                vec3 diff = color - PASTEL[i];
                float dist = dot(diff, diff);
                if (dist < minDist) { minDist = dist; bestColor = PASTEL[i]; }
            }
        #endif
        return bestColor;
    #endif
}

#endif