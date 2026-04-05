#version 400 core

layout(location = 0) out vec4 Accumulation;
layout(location = 1) out float Revealage;

in vec2 TexCoord;
in vec3 Normal;
in vec3 Tangent;
in vec3 FragPos;

uniform sampler2D image; // @fallback white
uniform sampler2D normalMap; // @fallback normal
uniform vec3 cameraPos;

// Material properties with sensible defaults
uniform vec3 baseColour = vec3(1.0, 1.0, 1.0);
uniform float diffuseStrength = 0.5;
uniform float specularStrength = 0.7;
uniform float specularPower = 32.0;
uniform float roughness = 0.5;
uniform float opacity = 0.5;

#include "lighting/lighting.glsl"

void main()
{
    // Sample texture and apply base colour tint
    vec4 texSample = texture(image, TexCoord);
    vec3 colour = texSample.rgb * baseColour;
    float alpha = texSample.a * opacity;

    // Discard fully transparent fragments
    if (alpha < 0.01) discard;

    // Calculate world-space normal (with normal mapping if available)
    vec3 sampledNormal = texture(normalMap, TexCoord).rgb * 2.0 - 1.0;
    vec3 n = normalize(Normal);
    vec3 t = normalize(Tangent);
    vec3 norm = n;

    if (length(t) > 0.0 && (sampledNormal.r + sampledNormal.g + sampledNormal.b) > 0.0) {
        vec3 b = cross(t, n);
        mat3 TBN = mat3(t, b, n);
        norm = normalize(TBN * normalize(sampledNormal));
    }

    // Calculate lighting
    vec3 viewDir = normalize(cameraPos - FragPos);
    vec3 result = CalcAllLights(norm, FragPos, viewDir, diffuseStrength, specularStrength, specularPower);

    vec4 premultiplied = vec4(colour * result * alpha, alpha);

    // Weighted blended OIT weight function (McGuire & Bavoil 2013)
    // Weight based on depth - closer fragments get more weight
    float z = gl_FragCoord.z;
    float weight = clamp(pow(min(1.0, alpha * 10.0) + 0.01, 3.0) * 1e8 *
                         pow(1.0 - z * 0.9, 3.0), 1e-2, 3e3);

    // Accumulation: premultiplied color * weight
    Accumulation = vec4(premultiplied.rgb * weight, alpha * weight);

    // Revealage: how much background shows through
    Revealage = alpha;
}
