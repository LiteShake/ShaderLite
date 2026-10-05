#version 330 compatibility

// #define SHADOWS
// #define GRID
#define GRID_MODE 0 // Grid pattern: 0 = squares, 1 = triangles [0 1]
#define GRID_DENSITY 2 // Grid squares per block: 1 = full block, 2 = half block, 4 = quarter block [1 2 4]
#define GRID_SIDES // Also draw the grid on vertical faces
#define TEXTURES // Blend a hint of the original texture detail over the palette colors
#define TEXTURE_STRENGTH 0.25 // How strong the texture hint is [0.1 0.25 0.5 0.75 1.0]

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

    #ifdef TEXTURES
    // Add only the texture's detail (pixel minus tile average) so the palette hue is kept
    #if PALETTE >= 2
    // monochrome palettes: brightness detail only, so no color leaks in
    vec3 texDetail = vec3(paletteLuma(origTex.rgb) - paletteLuma(avgColor.rgb));
    #else
    vec3 texDetail = origTex.rgb - avgColor.rgb;
    #endif
    flatColor = clamp(flatColor + texDetail * TEXTURE_STRENGTH, 0.0, 1.0);
    #endif

    vec3 finalColor = applyVertexTint(flatColor, glcolor.rgb) * texture(lightmap, lmcoord).rgb;

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
    float lineDist = min(grid.x, grid.y);

    #if GRID_MODE == 1
    // Triangles: split every square with a diagonal (like a triangulated mesh)
    float diag = gridPos.x + gridPos.y;
    float dDiag = abs(fract(diag - 0.5) - 0.5) / max(fwidth(diag), 1e-5);
    lineDist = min(lineDist, dDiag);
    #endif

    float gridMask = 1.0 - min(lineDist, 1.0);

    // Fade out where lines would shimmer (far away / grazing) and with distance
    float aaFade   = 1.0 - smoothstep(0.5, 1.0, max(fw.x, fw.y));
    float distFade = 1.0 - smoothstep(48.0, 96.0, length(worldPos));

    finalColor = mix(finalColor, paletteLineColor(), gridMask * strength * aaFade * distFade);
    #endif

    color = vec4(finalColor, origTex.a);
    // world-space block normal, alpha=1 marks "valid"
    normalOut = vec4(normalize(worldNormal) * 0.5 + 0.5, 1.0);
}