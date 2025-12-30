#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;

void main()
{
    float depth = texture(depthTexture, TexCoords).r;
    // Visualize depth (linearize for better visualization)
    float near = 0.1;
    float far = 100.0;
    float linearDepth = (2.0 * near) / (far + near - depth * (far - near));
    color = vec4(vec3(linearDepth), 1.0);
}
