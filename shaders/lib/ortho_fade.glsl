#ifndef ORTHO_FADE_GLSL
#define ORTHO_FADE_GLSL

// Orthographic view: cull (fade) blocks above the player's head on the camera side.
// Fragment shaders only (uses gl_FragCoord). Needs ORTHO_VIEW on to do anything.
#define ORTHO_FADE // Fade blocks that sit between the camera and the player (ortho view)
#define ORTHO_FADE_RADIUS 3.0 // Radius of the culled zone around the player, in blocks [1.0 2.0 3.0 5.0 8.0]
#define ORTHO_FADE_OPACITY 0.25 // How much of a faded block stays visible (0 = fully hidden) [0.0 0.15 0.25 0.4 0.6]
#define ORTHO_FADE_LENGTH 24.0 // How far the culled zone reaches toward the camera, in blocks [12.0 24.0 48.0 96.0]

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
//
// The culled zone is a corridor in world space, seen from above: ORTHO_FADE_RADIUS
// wide (each side of the player), running from the player toward the camera for
// ORTHO_FADE_LENGTH blocks. It only affects blocks at or above the player's head,
// so everything beside, below or behind the player is never touched.
bool orthoFadeDiscard(vec3 absPos, vec3 normal) {
    #if defined(ORTHO_VIEW) && defined(ORTHO_FADE)
        // Whole-block decision: use the block this fragment belongs to
        vec3 blockCenter = floor(absPos - normal * 0.01) + 0.5;

        // Only blocks that start at or above the player's head level
        if (blockCenter.y - 0.5 < eyePosition.y) return false;

        // Horizontal direction from the player toward the camera (world space).
        // = world-space direction of view-space +z, flattened to the ground plane.
        vec2 back = vec2(gbufferModelView[0][2], gbufferModelView[2][2]);
        float backLen = length(back);
        back = (backLen > 0.001) ? back / backLen : vec2(0.0, 1.0);

        // Where is this block relative to the player, on the ground plane?
        vec2 offset = blockCenter.xz - eyePosition.xz;
        float t = dot(offset, back);                 // > 0 = toward the camera

        // Blocks on the far side of the player can never be between him and the camera
        if (t < -0.5) return false;

        // Distance to the segment [player -> player + back * LENGTH]
        float d = length(offset - back * clamp(t, 0.0, ORTHO_FADE_LENGTH));
        float r = ORTHO_FADE_RADIUS;
        if (d > r) return false;

        // Soft edge: blocks at the rim stay more visible
        float keep = mix(ORTHO_FADE_OPACITY, 1.0, smoothstep(r * 0.6, r, d));
        return orthoBayer4(ivec2(gl_FragCoord.xy)) >= keep;
    #else
        return false;
    #endif
}

#endif