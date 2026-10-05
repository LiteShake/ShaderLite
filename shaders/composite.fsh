#version 330 compatibility

// #define SHADOWS
// #define DEBUG_SHADOWS

#include "/lib/palette.glsl"

// Shadow map settings: Iris reads these from the shader source, NOT shaders.properties
const int   shadowMapResolution     = 4096;
const float shadowDistance          = 128.0;
const bool  shadowHardwareFiltering = false; // we do our own compare below
const bool  shadowtex0Nearest       = true;  // hard, unfiltered depth reads

uniform sampler2D colortex0;
uniform sampler2D colortex1; // world normals from terrain (a=1 if valid)
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform vec3 shadowLightPosition; // view space, points toward the sun/moon

uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec2 texelSize = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    vec4 scene = texture(colortex0, texcoord);
    float depth = texture(depthtex0, texcoord).r;

    // ------------------------------------------------------------
    // 1. OUTLINES
    // ------------------------------------------------------------
    float edge = 0.0;
    if (depth < 0.9999) {
        float dRight = texture(depthtex0, texcoord + vec2(texelSize.x, 0.0)).r;
        float dLeft  = texture(depthtex0, texcoord - vec2(texelSize.x, 0.0)).r;
        float dUp    = texture(depthtex0, texcoord + vec2(0.0, texelSize.y)).r;
        float dDown  = texture(depthtex0, texcoord - vec2(0.0, texelSize.y)).r;

        float dx = abs(dRight - dLeft);
        float dy = abs(dUp - dDown);
        edge = step(0.002, dx + dy);
    }

    // ------------------------------------------------------------
    // 2. HARD SHADOWS
    // ------------------------------------------------------------
    float shadow = 1.0;
    #ifdef SHADOWS
    // derivatives must be taken outside branches
    vec4 clipPos = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos4 = gbufferProjectionInverse * clipPos;
    vec3 viewPos = viewPos4.xyz / viewPos4.w;
    vec3 derivNormalView = normalize(cross(dFdx(viewPos), dFdy(viewPos)));
    if (dot(derivNormalView, -viewPos) < 0.0) derivNormalView = -derivNormalView;
    vec3 derivNormalWorld = mat3(gbufferModelViewInverse) * derivNormalView;

    if (depth < 0.9999) {
        // camera-relative world space (what the shadow matrices expect)
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

        // Prefer the real block normal; fall back to derivatives (entities etc.)
        vec4 nTex = texture(colortex1, texcoord);
        vec3 worldNormal = (nTex.a > 0.5) ? normalize(nTex.xyz * 2.0 - 1.0)
                                          : derivNormalWorld;
        vec3 lightDir = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition);
        float NdotL = dot(worldNormal, lightDir);

        if (NdotL <= 0.0) {
            // facing away from the light = in shadow
            shadow = 0.0;
        } else {
            // Bias scales with one shadow texel and with the slope to the light
            float texelWorld = (2.0 * shadowDistance) / float(shadowMapResolution);
            float slope = min(sqrt(max(1.0 - NdotL * NdotL, 0.0)) / max(NdotL, 0.1), 6.0);
            vec3 biasedPos = worldPos + worldNormal * texelWorld * (1.0 + slope);

            vec4 shadowPos = shadowProjection * (shadowModelView * vec4(biasedPos, 1.0));
            vec3 shadowCoord = shadowPos.xyz / shadowPos.w * 0.5 + 0.5;

            if (all(greaterThan(shadowCoord.xy, vec2(0.0))) &&
                all(lessThan(shadowCoord.xy, vec2(1.0))) &&
                shadowCoord.z < 1.0) {
                float shadowDepth = texture(shadowtex0, shadowCoord.xy).r;
                if (shadowDepth < shadowCoord.z - (0.0004 + 0.0002 * slope)) {
                    shadow = 0.0;
                }
            }
        }
    }
    #endif

    // ------------------------------------------------------------
    // 3. APPLY EFFECTS
    // ------------------------------------------------------------
    vec3 finalColor = scene.rgb;

    #ifdef DEBUG_SHADOWS
        finalColor = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), shadow);
    #else
        #ifdef SHADOWS
        finalColor = mix(finalColor * 0.5, finalColor, shadow);
        #endif
    #endif

    finalColor = mix(finalColor, paletteLineColor(), edge);

    color = vec4(finalColor, scene.a);
}