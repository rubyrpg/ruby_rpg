#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform float intensity; // 0.0 = full color, 1.0 = full grayscale

void main()
{
    vec4 texColor = texture(screenTexture, TexCoords);
    float gray = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);
    color = vec4(mix(texColor.rgb, grayscale, intensity), texColor.a);
}
