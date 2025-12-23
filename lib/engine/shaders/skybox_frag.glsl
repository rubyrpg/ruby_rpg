#version 330 core

in vec3 FragPos;
out vec4 color;

uniform vec3 horizonColour;
uniform vec3 skyColour;

void main()
{
    float mixFactor = clamp(FragPos.y / 2.0, 0.0, 1.0);
    vec3 result = mix(horizonColour, skyColour, mixFactor);
    color = vec4(result, 1.0);
}
