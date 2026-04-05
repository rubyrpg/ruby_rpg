#version 400 core

#include "oit/oit.glsl"

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;

uniform vec3 cameraPos;
uniform float opacity = 0.3;
uniform vec3 baseColour = vec3(1.0, 0.0, 0.0);
uniform float distortionStrength = 0.03;

void main()
{
    vec2 screenUV = OitScreenUV();
    vec2 offset = vec2(distortionStrength, 0.0);
    vec3 distorted = OitSampleOpaqueUV(screenUV + offset);

    // Tint via OIT (writes default passthrough to distortion buffer)
    OitOutput(baseColour, opacity);

    // Override distortion buffer with warped scene (must be after OitOutput)
    OitDistort(distorted);
}
