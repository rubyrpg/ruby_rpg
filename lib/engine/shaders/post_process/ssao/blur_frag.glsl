#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D ssaoTexture;
uniform sampler2D depthTexture;
uniform int blurSize;
uniform float depthThreshold;

float linearizeDepth(float d, float near, float far) {
    return near * far / (far - d * (far - near));
}

void main() {
    vec2 texelSize = 1.0 / vec2(textureSize(ssaoTexture, 0));
    float centerDepth = texture(depthTexture, TexCoords).r;

    // Skip skybox
    if (centerDepth >= 1.0) {
        FragColor = vec4(1.0);
        return;
    }

    float result = 0.0;
    float weightSum = 0.0;

    for (int x = -blurSize; x <= blurSize; x++) {
        for (int y = -blurSize; y <= blurSize; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            vec2 sampleCoord = TexCoords + offset;

            float sampleDepth = texture(depthTexture, sampleCoord).r;

            // Edge-aware: reduce weight for samples with very different depth
            float depthDiff = abs(centerDepth - sampleDepth);
            float depthWeight = 1.0 / (1.0 + depthDiff * depthThreshold);

            // Spatial weight (simple box for now, could use gaussian)
            float spatialWeight = 1.0;

            float weight = depthWeight * spatialWeight;
            result += texture(ssaoTexture, sampleCoord).r * weight;
            weightSum += weight;
        }
    }

    float ao = result / weightSum;
    FragColor = vec4(ao, ao, ao, 1.0);
}
