#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;   // Opaque scene
uniform sampler2D accumTexture;    // OIT accumulation
uniform sampler2D revealTexture;   // OIT revealage

void main()
{
    vec4 accum = texture(accumTexture, TexCoords);
    float revealage = texture(revealTexture, TexCoords).r;

    // No transparent fragments at this pixel
    if (revealage == 1.0) {
        color = texture(screenTexture, TexCoords);
        return;
    }

    // Weighted average color
    vec3 avgColor = accum.rgb / max(accum.a, 1e-5);

    // Composite: transparent over opaque
    vec3 opaqueColor = texture(screenTexture, TexCoords).rgb;
    color = vec4(avgColor * (1.0 - revealage) + opaqueColor * revealage, 1.0);
}
