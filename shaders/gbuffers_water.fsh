
#version 330 compatibility

#include "/lib/palette.glsl"

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
    vec3 flatColor = snapToPalette(avgColor.rgb);

    // Set water opacity (0.8 = 80% visible)
    float waterAlpha = 0.8; 
    
    color = vec4(flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb, waterAlpha);
}
