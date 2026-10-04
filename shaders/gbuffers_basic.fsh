#version 330 compatibility

// #define NORMAL_PALETTE
// #define SHADOWS
// #define GRID

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec4 origTex = texture(gtexture, texcoord);
    if (origTex.a < alphaTestRef) {
        discard;
    }

    vec4 avgColor = textureLod(gtexture, texcoord, 10.0);
    vec3 flatColor = floor(avgColor.rgb * 6.0) / 6.0;

    color = vec4(flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb, origTex.a);
}