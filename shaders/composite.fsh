#version 330 compatibility

uniform sampler2D colortex0; // The rendered scene
uniform sampler2D depthtex0; // The depth buffer
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
    // 1. OUTLINES (Edge Detection)
    // ------------------------------------------------------------
    float edge = 0.0;
    
    // Skip the sky (depth of 1.0 means "infinity")
    if (depth < 0.9999) {
        float dRight = texture(depthtex0, texcoord + vec2(texelSize.x, 0.0)).r;
        float dLeft  = texture(depthtex0, texcoord - vec2(texelSize.x, 0.0)).r;
        float dUp    = texture(depthtex0, texcoord + vec2(0.0, texelSize.y)).r;
        float dDown  = texture(depthtex0, texcoord - vec2(0.0, texelSize.y)).r;

        // Check for sudden depth changes (which means an edge)
        float dx = abs(dRight - dLeft);
        float dy = abs(dUp - dDown);
        
        // Threshold to prevent noise on smooth surfaces
        edge = step(0.002, dx + dy); 
    }

    // ------------------------------------------------------------
    // 2. DROP SHADOW (SketchUp style)
    // ------------------------------------------------------------
    float shadow = 0.0;
    
    if (depth < 0.9999) {
        // Sample the depth a few pixels towards bottom-right.
        // Change the '4.0' to make the shadow longer or shorter.
        float shadowDepth = texture(depthtex0, texcoord + texelSize * 4.0).r;
        
        // If the sampled depth is closer (smaller) than the current depth, 
        // it means something is blocking the light/line of sight.
        if (shadowDepth < depth - 0.0001) {
            shadow = 1.0;
        }
    }

    // ------------------------------------------------------------
    // 3. APPLY EFFECTS
    // ------------------------------------------------------------
    vec3 finalColor = scene.rgb;
    
    // Darken shadowed areas by 35%
    finalColor = mix(finalColor, finalColor * 0.65, shadow);
    
    // Draw outlines (dark grey)
    finalColor = mix(finalColor, vec3(0.15), edge);

    color = vec4(finalColor, scene.a);
}