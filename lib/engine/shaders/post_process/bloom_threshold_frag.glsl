#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform float threshold;

void main()
{
    vec3 texColor = texture(screenTexture, TexCoords).rgb;
    float brightness = dot(texColor, vec3(0.2126, 0.7152, 0.0722));

    if (brightness > threshold) {
        color = vec4(texColor, 1.0);
    } else {
        color = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
