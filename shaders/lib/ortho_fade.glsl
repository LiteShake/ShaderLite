#ifndef ORTHO_FADE_GLSL
#define ORTHO_FADE_GLSL

// Orthographic view: cull (fade) blocks above the player's head, between the head and the camera.
// Fragment shaders only (uses gl_FragCoord). Needs ORTHO_VIEW on to do anything.
#define ORTHO_FADE // Fade blocks that sit between the camera and the player (ortho view)
#define ORTHO_FADE_RADIUS 3.0 // Radius of the culling cylinder around the player, in blocks [1.0 2.0 3.0 5.0 8.0]
#define ORTHO_FADE_OPACITY 0.25 // How much of a faded block stays visible (0 = fully hidden) [0.0 0.15 0.25 0.4 0.6]
#define ORTHO_FADE_LENGTH 24.0 // How far toward the camera the cylinder reaches, in blocks [12.0 24.0 48.0 96.0]

uniform vec3 eyePosition;     // player's eyes, absolute world space
uniform vec3 cameraPosition;  // camera, absolute world space
uniform mat4 gbufferModelView;

float orthoBayer4(ivec2 p) {
    const float m[16] = float[16](0.0, 8.0, 2.0, 10.0,
                                  12.0, 4.0, 14.0, 6.0,
                                  3.0, 11.0, 1.0, 9.0,
                                  15.0, 7.0, 13.0, 5.0);
    return (m[(p.x & 3) + (p.y & 3) * 4] + 0.5) / 16.0;
}

// absPos / normal: this fragment's absolute world position and face normal.
// Returns true if the block it belongs to should be faded away.
bool orthoFadeDiscard(vec3 absPos, vec3 normal) {
    #if defined(ORTHO_VIEW) && defined(ORTHO_FADE)
        // Whole-block decision: use the block this fragment belongs to
        vec3 blockCenter = floor(absPos - normal * 0.01) + 0.5;

        // Only blocks that start at or above the player's head level.
        // Ground, walls beside you and everything at body height stay untouched.
        if (blockCenter.y - 0.5 < eyePosition.y) return false;

        // Player's head in view space (camera is the origin, looking down -z)
        vec3 headView  = (gbufferModelView * vec4(eyePosition - cameraPosition, 1.0)).xyz;
        vec3 blockView = (gbufferModelView * vec4(blockCenter - cameraPosition, 1.0)).xyz;

        // In an orthographic view every ray from the camera runs parallel to -z,
        // so the ray from the head to the camera is the line (head.x, head.y, z >= head.z).
        float along = blockView.z - headView.z;
        if (along < 0.0 || along > ORTHO_FADE_LENGTH) return false;

        // Distance from that ray = the culling cylinder
        float dist = length(blockView.xy - headView.xy);
        float r = ORTHO_FADE_RADIUS;
        if (dist > r) return false;

        // Soft edge: blocks at the rim stay more visible
        float keep = mix(ORTHO_FADE_OPACITY, 1.0, smoothstep(r * 0.6, r, dist));
        return orthoBayer4(ivec2(gl_FragCoord.xy)) >= keep;
    #else
        return false;
    #endif
}

#endif