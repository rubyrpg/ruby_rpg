#version 400 core

layout(location = 0) out vec4 FragColour;
layout(location = 1) out vec4 normalRoughness;

in vec2 TexCoord;
in vec3 Normal;
in vec3 Tangent;
in vec3 FragPos;

uniform sampler2D image;
uniform sampler2D normalMap;
uniform float roughness;
uniform vec3 cameraPos;
uniform float diffuseStrength;
uniform float specularStrength;
uniform float specularPower;
uniform vec3 ambientLight;

#include "lighting/lighting.glsl"

void main()
{
    // Sample texture
    vec4 tex = texture(image, TexCoord);

    // Calculate world-space normal (with normal mapping if available)
    vec3 sampledNormal = texture(normalMap, TexCoord).rgb * 2.0 - 1.0;
    vec3 n = normalize(Normal);
    vec3 t = normalize(Tangent);
    vec3 norm = n;

    // Apply normal map if valid tangent exists
    if (length(t) > 0.0 && (sampledNormal.r + sampledNormal.g + sampledNormal.b) > 0.0) {
        vec3 b = cross(t, n);
        mat3 TBN = mat3(t, b, n);
        norm = normalize(TBN * normalize(sampledNormal));
    }

    // Calculate lighting
    vec3 viewDir = normalize(cameraPos - FragPos);
    vec3 result = CalcAllLights(norm, FragPos, viewDir, ambientLight, diffuseStrength, specularStrength, specularPower);

    FragColour = tex * vec4(result, 1.0);

    // Output world-space normal (encoded to 0-1) and roughness in alpha
    normalRoughness = vec4(norm * 0.5 + 0.5, roughness);
}
