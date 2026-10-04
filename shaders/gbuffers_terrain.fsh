#version 330 compatibility

// #define NORMAL_PALETTE
// #define SHADOWS
// #define GRID
#define GRID_DENSITY 2 // Grid squares per block: 1 = full block, 2 = half block, 4 = quarter block [1 2 4]
#define GRID_SIDES // Also draw the grid on vertical faces

#include "/lib/palette.glsl"

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef = 0.1;
uniform vec3 cameraPosition;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 worldPos;
in vec3 worldNormal;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalOut;

void main() {
    vec4 origTex = texture(gtexture, texcoord);
    if (origTex.a < alphaTestRef) {
        discard;
    }

    vec4 avgColor = textureLod(gtexture, texcoord, 10.0);
    vec3 flatColor = snapToPalette(avgColor.rgb);

    vec3 finalColor = flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb;

    // ------------------------------------------------------------
    // CAD GRID OVERLAY
    // ------------------------------------------------------------
    #ifdef GRID
    vec3 norm = normalize(worldNormal);
    vec3 absWorldPos = worldPos + cameraPosition;

    // Pick the two world axes lying in this face's plane
    vec3 an = abs(norm);
    vec2 planePos;
    float strength;
    if (an.y >= an.x && an.y >= an.z) {
        planePos = absWorldPos.xz;      // top / bottom faces
        strength = 0.5;
    } else {
        planePos = (an.x >= an.z) ? absWorldPos.zy : absWorldPos.xy; // side faces
        #ifdef GRID_SIDES
        strength = 0.3;                 // quieter than the top grid
        #else
        strength = 0.0;
        #endif
    }

    vec2 gridPos = planePos * float(GRID_DENSITY);
    vec2 fw = fwidth(gridPos);

    // Grid lines with anti-aliasing
    vec2 grid = abs(fract(gridPos - 0.5) - 0.5) / fw;
    float gridMask = 1.0 - min(min(grid.x, grid.y), 1.0);

    // Fade out where lines would shimmer (far away / grazing) and with distance
    float aaFade   = 1.0 - smoothstep(0.5, 1.0, max(fw.x, fw.y));
    float distFade = 1.0 - smoothstep(48.0, 96.0, length(worldPos));

    finalColor = mix(finalColor, vec3(0.1), gridMask * strength * aaFade * distFade);
    #endif

    color = vec4(finalColor, origTex.a);
    // world-space block normal, alpha=1 marks "valid"
    normalOut = vec4(normalize(worldNormal) * 0.5 + 0.5, 1.0);
}