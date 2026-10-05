#version 330 compatibility

#include "/lib/ortho.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

void main() {
    gl_Position = projectVertex(gl_ModelViewMatrix * gl_Vertex);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;

    #ifdef ORTHO_VIEW
    // the hand does not make sense in an orthographic view: push it off screen
    gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
    #endif
}