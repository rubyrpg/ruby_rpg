#version 400 core

in vec3 Normal;
in vec3 FragPos;

in vec3 Diffuse;
in vec3 Specular;
in vec3 Albedo;

out vec4 color;

uniform vec3 cameraPos;
uniform float diffuseStrength;
uniform float specularStrength;
uniform float specularPower;
uniform vec3 ambientLight;

#include "lighting.glsl"

void main()
{
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(cameraPos - FragPos);

    vec3 result = CalcAllLights(norm, FragPos, viewDir, ambientLight, diffuseStrength, specularStrength, specularPower);

    vec4 c = vec4(Diffuse, 1.0);
    color = c * vec4(result, 1.0);
}
