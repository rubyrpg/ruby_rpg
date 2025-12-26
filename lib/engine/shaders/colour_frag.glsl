#version 330 core

layout(location = 0) out vec4 FragColour;
layout(location = 1) out vec4 normalRoughness;

in vec4 ourColour;
in vec3 Normal;

uniform float roughness;

void main()
{
    FragColour = ourColour;
    // Output world-space normal (encoded to 0-1) and roughness
    vec3 norm = normalize(Normal);
    normalRoughness = vec4(norm * 0.5 + 0.5, roughness);
}