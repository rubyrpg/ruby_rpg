#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;  // original image
uniform sampler2D bloomTexture;   // blurred bright pixels
uniform float intensity;

void main()
{
    vec3 original = texture(screenTexture, TexCoords).rgb;
    vec3 bloom = texture(bloomTexture, TexCoords).rgb;

    // Debug: output red to verify shader runs
    // color = vec4(1.0, 0.0, 0.0, 1.0);

    color = vec4(original + bloom * intensity, 1.0);
}
