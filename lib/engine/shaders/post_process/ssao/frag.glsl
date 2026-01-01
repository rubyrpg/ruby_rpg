#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D depthTexture;
uniform sampler2D normalTexture;
uniform sampler2D noiseTexture;

uniform vec3 samples[64];
uniform int kernelSize;
uniform float radius;
uniform float bias;
uniform float power;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 inverseVP;
uniform float nearPlane;
uniform float farPlane;
uniform vec2 noiseScale;

float linearizeDepth(float d) {
    return nearPlane * farPlane / (farPlane - d * (farPlane - nearPlane));
}

vec3 viewPosFromDepth(vec2 uv, float depth) {
    // Reconstruct world position from depth
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 world = inverseVP * ndc;
    vec3 worldPos = world.xyz / world.w;
    // Transform to view space
    return (view * vec4(worldPos, 1.0)).xyz;
}

void main() {
    float depth = texture(depthTexture, TexCoords).r;

    // Skip skybox pixels
    if (depth >= 1.0) {
        FragColor = vec4(1.0);
        return;
    }

    // Get view-space position
    vec3 fragPos = viewPosFromDepth(TexCoords, depth);

    // Get world normal and transform to view space
    vec4 normalRough = texture(normalTexture, TexCoords);
    vec3 worldNormal = normalize(normalRough.rgb * 2.0 - 1.0);
    vec3 normal = normalize((view * vec4(worldNormal, 0.0)).xyz);

    // Get random rotation vector from noise texture
    vec3 randomVec = texture(noiseTexture, TexCoords * noiseScale).xyz;

    // Create TBN matrix (Gram-Schmidt process)
    vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN = mat3(tangent, bitangent, normal);

    // Sample hemisphere and accumulate occlusion
    float occlusion = 0.0;
    for (int i = 0; i < kernelSize; i++) {
        // Transform sample from tangent space to view space
        vec3 samplePos = TBN * samples[i];
        samplePos = fragPos + samplePos * radius;

        // Project sample to screen space
        vec4 offset = projection * vec4(samplePos, 1.0);
        offset.xyz /= offset.w;
        offset.xyz = offset.xyz * 0.5 + 0.5;

        // Sample depth at this screen position
        float sampleDepth = texture(depthTexture, offset.xy).r;

        // Skip if sample is outside screen
        if (offset.x < 0.0 || offset.x > 1.0 || offset.y < 0.0 || offset.y > 1.0) {
            continue;
        }

        // Skip skybox samples
        if (sampleDepth >= 1.0) {
            continue;
        }

        // Get view-space depth of the geometry at this sample
        float geometryDepth = -linearizeDepth(sampleDepth);

        // Range check to avoid occlusion from distant objects
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - geometryDepth));

        // Compare depths: if geometry is in front of sample, it's occluded
        occlusion += (geometryDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;
    }

    occlusion = 1.0 - (occlusion / float(kernelSize));
    float ao = pow(occlusion, power);
    FragColor = vec4(ao, ao, ao, 1.0);
}
