#version 330 compatibility

#include "/lib/ortho.glsl"

uniform float frameTimeCounter;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos;
out vec3 worldNormal;

void main() {
    vec4 viewPos4 = gl_ModelViewMatrix * gl_Vertex;
    worldPos = gl_Vertex.xyz;
    worldNormal = gl_Normal;
    gl_Position = projectVertex(viewPos4);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    // Wobble the water vertically
    gl_Position.y += sin(gl_Position.x * 2.0 + frameTimeCounter * 2.0) * 0.005;
}