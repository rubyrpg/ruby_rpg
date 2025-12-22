#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform vec2 direction; // (1,0) for horizontal, (0,1) for vertical
uniform float blurScale; // multiplier for sample spacing

// 9-tap gaussian weights
const float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

void main()
{
    vec2 texelSize = 1.0 / textureSize(screenTexture, 0);
    vec3 result = texture(screenTexture, TexCoords).rgb * weights[0];

    for (int i = 1; i < 5; i++) {
        vec2 offset = direction * texelSize * float(i) * blurScale;
        result += texture(screenTexture, TexCoords + offset).rgb * weights[i];
        result += texture(screenTexture, TexCoords - offset).rgb * weights[i];
    }

    color = vec4(result, 1.0);
}
