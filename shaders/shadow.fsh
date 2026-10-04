#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

void main() {
    vec4 tex = texture(gtexture, texcoord);
    if (tex.a < alphaTestRef) {
        discard;
    }
}