#ifndef ORTHO_GLSL
#define ORTHO_GLSL

// Orthographic camera
// #define ORTHO_VIEW
#define ORTHO_SIZE 32 // Visible height in blocks (smaller = more zoomed in) [8 16 32 64 128]

uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferProjectionInverse;

// Depth box around the camera, in blocks (things behind the camera show too)
const float ORTHO_NEAR = -128.0;
const float ORTHO_FAR  =  128.0;

// View space -> clip space. Replaces gl_ProjectionMatrix * viewPos in vertex shaders.
vec4 projectVertex(vec4 viewPos) {
    #ifdef ORTHO_VIEW
        float halfH = float(ORTHO_SIZE) * 0.5;
        float halfW = halfH * (viewWidth / viewHeight);
        return vec4(viewPos.x / halfW,
                    viewPos.y / halfH,
                    (-2.0 * viewPos.z - (ORTHO_FAR + ORTHO_NEAR)) / (ORTHO_FAR - ORTHO_NEAR),
                    1.0);
    #else
        return gl_ProjectionMatrix * viewPos;
    #endif
}

// Screen uv + depth buffer value -> view space position (inverse of the above)
vec3 viewPosFromDepth(vec2 uv, float depth) {
    vec3 ndc = vec3(uv, depth) * 2.0 - 1.0;
    #ifdef ORTHO_VIEW
        float halfH = float(ORTHO_SIZE) * 0.5;
        float halfW = halfH * (viewWidth / viewHeight);
        return vec3(ndc.x * halfW,
                    ndc.y * halfH,
                    -(ndc.z * (ORTHO_FAR - ORTHO_NEAR) + (ORTHO_FAR + ORTHO_NEAR)) * 0.5);
    #else
        vec4 v = gbufferProjectionInverse * vec4(ndc, 1.0);
        return v.xyz / v.w;
    #endif
}

// Direction from a surface toward the camera, in view space
vec3 viewDirToCamera(vec3 viewPos) {
    #ifdef ORTHO_VIEW
        return vec3(0.0, 0.0, 1.0);
    #else
        return -viewPos;
    #endif
}

#endif