#version 400 core

#include "oit/oit.glsl"

in vec2 TexCoord;
in vec3 Normal;
in vec3 FragPos;

uniform mat4 camera;
uniform mat4 viewMatrix;
uniform vec3 cameraPos;
uniform float opacity = 0.3;
uniform vec3 baseColour = vec3(1.0, 0.0, 0.0);
uniform float distortionStrength = 0.03;

void main()
{
    vec3 norm = normalize(Normal);

    // Transform normal to view space (no aspect ratio distortion)
    vec3 viewNorm = normalize(mat3(viewMatrix) * norm);

    // Use view-space normal XY as distortion offset
    vec2 offset = viewNorm.xy * distortionStrength;

    vec2 screenUV = OitScreenUV();
    vec3 distorted = OitSampleOpaqueUV(screenUV + offset);

    // Tint via OIT
    OitOutput(baseColour, opacity);

    // Write warped scene to distortion buffer
    OitDistort(distorted);
}
