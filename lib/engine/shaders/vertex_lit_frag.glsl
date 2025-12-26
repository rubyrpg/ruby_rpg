#version 400 core

in vec3 Normal;
in vec3 FragPos;

in vec3 Diffuse;
in vec3 Specular;
in vec3 Albedo;

layout(location = 0) out vec4 FragColour;
layout(location = 1) out vec4 normalRoughness;

uniform vec3 cameraPos;
uniform float roughness;
uniform float diffuseStrength;
uniform float specularStrength;
uniform float specularPower;
uniform vec3 ambientLight;

#include "lighting/lighting.glsl"

void main()
{
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(cameraPos - FragPos);

    vec3 result = CalcAllLights(norm, FragPos, viewDir, ambientLight, diffuseStrength, specularStrength, specularPower);

    vec4 c = vec4(Diffuse, 1.0);
    FragColour = c * vec4(result, 1.0);

    // Output world-space normal (encoded to 0-1) and roughness in alpha
    normalRoughness = vec4(norm * 0.5 + 0.5, roughness);
}
