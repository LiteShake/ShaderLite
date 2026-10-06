#version 330 compatibility

#include "/lib/ortho.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos;
out vec3 worldNormal;

void main() {
    vec4 viewPos4 = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = projectVertex(viewPos4);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    
    // Pass the raw position and normal
    worldPos = gl_Vertex.xyz;
    worldNormal = gl_Normal;
}