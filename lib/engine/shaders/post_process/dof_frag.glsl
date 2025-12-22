#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform float focusDistance;  // depth value of focal plane (0-1 range)
uniform float focusRange;     // how wide the in-focus range is
uniform float blurAmount;     // max blur strength

void main()
{
    float depth = texture(depthTexture, TexCoords).r;

    // Calculate circle of confusion - only blur things FARTHER than focus
    // (depth > focusDistance means farther from camera)
    float coc = max(0.0, depth - focusDistance) / focusRange;
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
