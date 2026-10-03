
#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    // 1. Handle transparency (leaves, glass, tall grass)
    vec4 origTex = texture(gtexture, texcoord);
    if (origTex.a < alphaTestRef) {
        discard;
    }

    // 2. Get the "primary color" by sampling the highest mipmap level
    // LOD 10.0 forces it to average the texture down to a 1x1 pixel
    vec4 avgColor = textureLod(gtexture, texcoord, 10.0);

    // 3. Quantize (Posterize) the color to 6 levels per channel
    // This removes all texture detail and creates that flat Sketchup look
    vec3 flatColor = floor(avgColor.rgb * 6.0) / 6.0;

    // 4. Apply biome tint (glcolor) and lighting (lightmap)
    color = vec4(flatColor * glcolor.rgb * texture(lightmap, lmcoord).rgb, 1.0);
}