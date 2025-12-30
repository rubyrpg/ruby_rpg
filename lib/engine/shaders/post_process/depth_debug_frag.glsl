#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;

void main()
{
    float depth = texture(depthTexture, TexCoords).r;

    // DEBUG: Red if depth exactly 0, green if depth exactly 1, else show depth
    if (depth == 0.0) {
        color = vec4(1.0, 0.0, 0.0, 1.0);  // RED = depth is 0
    } else if (depth >= 0.999) {
        color = vec4(0.0, 1.0, 0.0, 1.0);  // GREEN = depth is ~1
    } else {
        color = vec4(depth, depth, depth, 1.0);  // GREY = somewhere in between
    }
}
