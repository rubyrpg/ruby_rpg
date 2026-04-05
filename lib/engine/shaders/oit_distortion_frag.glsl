#version 400 core

#include "oit/oit.glsl"

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;

uniform vec3 cameraPos;
uniform float opacity = 0.3;
uniform vec3 baseColour = vec3(1.0, 0.0, 0.0);
uniform float distortionStrength = 0.03;
uniform float refractionIndex = 0.95;

void main()
{
    vec3 viewDir = normalize(FragPos - cameraPos);
    vec3 norm = normalize(Normal);

    // Refract the view ray through the surface
    vec3 refracted = refract(viewDir, norm, refractionIndex);

    // UV offset from refraction
    vec2 offset = (refracted.xy - viewDir.xy) * distortionStrength;

    vec2 screenUV = OitScreenUV();
    vec3 distorted = OitSampleOpaqueUV(screenUV + offset);

    // Tint via OIT
    OitOutput(baseColour, opacity);

    // Write warped scene to distortion buffer
    OitDistort(distorted);
}
