#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform samplerCube skyboxCubemap;
uniform mat4 inverseVP;
uniform vec3 cameraPos;

void main()
{
    float depth = texture(depthTexture, TexCoords).r;

    // If depth < 1.0, this is geometry - keep existing color
    if (depth < 0.999) {
        FragColor = texture(screenTexture, TexCoords);
        return;
    }

    // Sky pixel: reconstruct view direction and sample cubemap
    vec4 ndc = vec4(TexCoords * 2.0 - 1.0, 1.0, 1.0);
    vec4 worldPos = inverseVP * ndc;
    vec3 viewDir = normalize(worldPos.xyz / worldPos.w - cameraPos);

    FragColor = texture(skyboxCubemap, viewDir);
}
