#ifndef ORTHO_FADE_GLSL
#define ORTHO_FADE_GLSL

// Orthographic view: see-through blocks between the camera and the player.
#define ORTHO_FADE 
#define ORTHO_FADE_RADIUS 3 // How far around the player blocks fade, in blocks [2 3 4 6 8]
#define ORTHO_FADE_OPACITY 0.25 // How much of a faded block stays visible (0 = fully hidden) [0.0 0.15 0.25 0.4 0.6]

uniform vec3 eyePosition;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

float orthoBayer4(ivec2 p) {
    const float m[16] = float[16](0.0, 8.0, 2.0, 10.0,
                                  12.0, 4.0, 14.0, 6.0,
                                  3.0, 11.0, 1.0, 9.0,
                                  15.0, 7.0, 13.0, 5.0);
    return (m[(p.x & 3) + (p.y & 3) * 4] + 0.5) / 16.0;
}

// Returns true if this fragment should be dithered away.
bool orthoFadeDiscard(vec3 fragView) {
    #if defined(ORTHO_VIEW) && defined(ORTHO_FADE)
        // 1. Convert fragment from view space to world space
        vec3 fragWorld = (gbufferModelViewInverse * vec4(fragView, 1.0)).xyz + cameraPosition;

        // 2. Get the player's absolute world position
        vec3 playerWorld = eyePosition;

        // 3. Calculate horizontal (XZ) distance from fragment to player
        vec2 relXZ = fragWorld.xz - playerWorld.xz;
        float distXZ = length(relXZ);

        // 4. Calculate vertical height above the player's head
        // (Player's head is roughly eye level minus 0.2 blocks)
        float heightAboveHead = fragWorld.y - (playerWorld.y - 0.2);

        // 5. Only fade blocks strictly above the head
        if (heightAboveHead < 0.0) return false;

        // 6. Fade based on horizontal distance (creates a clean vertical cylinder)
        float r = float(ORTHO_FADE_RADIUS);
        float keep = mix(ORTHO_FADE_OPACITY, 1.0, smoothstep(r * 0.5, r, distXZ));

        // 7. Bayer dithering
        return orthoBayer4(ivec2(gl_FragCoord.xy)) >= keep;
    #else
        return false;
    #endif
}

#endif