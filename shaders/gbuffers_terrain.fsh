#version 330 compatibility

// #define NORMAL_PALETTE 

#include "/lib/palette.glsl" 

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
    color = vec4(flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb * 0.8, origTex.a);
}