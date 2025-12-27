#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform float focusDistance;  // world-space distance in meters
uniform float focusRange;     // distance over which blur ramps up (meters)
uniform float blurAmount;     // max blur strength
uniform float nearPlane;
uniform float farPlane;

float linearizeDepth(float d) {
    return nearPlane * farPlane / (farPlane - d * (farPlane - nearPlane));
}

void main()
{
    float depth = texture(depthTexture, TexCoords).r;
    float linearDepth = linearizeDepth(depth);

    // Calculate circle of confusion - only blur things FARTHER than focus
    float coc = max(0.0, linearDepth - focusDistance) / focusRange;
    coc = clamp(coc, 0.0, 1.0) * blurAmount;

    // Simple box blur with variable radius based on CoC
    vec2 texelSize = 1.0 / textureSize(screenTexture, 0);
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;

    int samples = int(coc * 4.0) + 1; // 1-5 samples per axis

    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize * coc;
            result += texture(screenTexture, TexCoords + offset).rgb;
            totalWeight += 1.0;
        }
    }

    result /= totalWeight;
    color = vec4(result, 1.0);
}
