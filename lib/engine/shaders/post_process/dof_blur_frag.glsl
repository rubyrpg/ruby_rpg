#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform vec2 direction;        // (1,0) horizontal, (0,1) vertical
uniform float focusDistance;
uniform float focusRange;
uniform float blurAmount;
uniform float nearPlane;
uniform float farPlane;

float linearizeDepth(float d) {
    return nearPlane * farPlane / (farPlane - d * (farPlane - nearPlane));
}

float calcCoC(vec2 uv) {
    float depth = texture(depthTexture, uv).r;
    float linear = linearizeDepth(depth);
    float coc = max(0.0, linear - focusDistance) / focusRange;
    return clamp(coc, 0.0, 1.0) * blurAmount;
}

void main()
{
    float centerCoC = calcCoC(TexCoords);

    // Early out for sharp pixels
    if (centerCoC < 0.01) {
        color = texture(screenTexture, TexCoords);
        return;
    }

    vec2 texelSize = 1.0 / textureSize(screenTexture, 0);
    vec3 result = texture(screenTexture, TexCoords).rgb;
    float totalWeight = 1.0;

    int samples = int(centerCoC * 4.0) + 1;

    for (int i = 1; i <= samples; i++) {
        vec2 offset = direction * texelSize * float(i) * centerCoC;

        // Sample both directions
        result += texture(screenTexture, TexCoords + offset).rgb;
        result += texture(screenTexture, TexCoords - offset).rgb;
        totalWeight += 2.0;
    }

    color = vec4(result / totalWeight, 1.0);
}
