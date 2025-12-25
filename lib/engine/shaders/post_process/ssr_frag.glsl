#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform sampler2D normalTexture;

uniform mat4 inverseVP;
uniform mat4 viewProj;
uniform vec3 cameraPos;

uniform float maxSteps;
uniform float stepSize;
uniform float thickness;

vec3 worldPosFromDepth(vec2 uv, float depth) {
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 world = inverseVP * ndc;
    return world.xyz / world.w;
}

float getDepthAt(vec3 worldPos) {
    vec4 clip = viewProj * vec4(worldPos, 1.0);
    return (clip.z / clip.w) * 0.5 + 0.5;
}

vec2 worldToScreen(vec3 worldPos, out bool valid) {
    vec4 clip = viewProj * vec4(worldPos, 1.0);
    valid = clip.w > 0.0;  // Invalid if behind camera
    return clip.xy / clip.w * 0.5 + 0.5;
}

void main() {
    vec4 baseColor = texture(screenTexture, TexCoords);
    float depth = texture(depthTexture, TexCoords).r;

    // Skip sky/background
    if (depth >= 1.0) {
        FragColor = baseColor;
        return;
    }

    // Get roughness early to skip non-reflective surfaces
    vec4 normalRough = texture(normalTexture, TexCoords);
    float roughness = normalRough.a;

    // Skip very rough (matte) surfaces - no point ray marching
    if (roughness > 0.9) {
        FragColor = baseColor;
        return;
    }

    // Convert roughness to reflectivity (0 = rough/matte, 1 = smooth/mirror)
    float reflectivity = 1.0 - roughness;

    // Reconstruct world position and normal
    vec3 worldPos = worldPosFromDepth(TexCoords, depth);
    vec3 normal = normalize(normalRough.rgb * 2.0 - 1.0);

    // Calculate reflection direction
    vec3 viewDir = normalize(worldPos - cameraPos);
    vec3 reflectDir = reflect(viewDir, normal);


    // Ray march in world space
    vec3 rayPos = worldPos + reflectDir * 2.0;  // Larger offset to avoid self-hit
    vec4 reflectionColor = vec4(0.0);

    for (int i = 0; i < int(maxSteps); i++) {
        rayPos += reflectDir * stepSize;

        bool validProj;
        vec2 screenPos = worldToScreen(rayPos, validProj);
        if (!validProj) break;

        // Check bounds
        if (screenPos.x < 0.0 || screenPos.x > 1.0 ||
            screenPos.y < 0.0 || screenPos.y > 1.0) {
            break;
        }

        // Compare depths directly (avoid world pos reconstruction)
        float rayDepth = getDepthAt(rayPos);
        float sceneDepth = texture(depthTexture, screenPos).r;

        // Skip sky
        if (sceneDepth >= 1.0) continue;

        // Check if ray is close to scene surface (either side)
        float depthDiff = rayDepth - sceneDepth;

        if (abs(depthDiff) < thickness) {
            // Hit! Apply fading
            float edgeFadeX = 1.0 - pow(abs(screenPos.x - 0.5) * 2.0, 2.0);
            float edgeFadeY = 1.0 - pow(abs(screenPos.y - 0.5) * 2.0, 2.0);
            float edgeFade = clamp(edgeFadeX * edgeFadeY, 0.0, 1.0);
            float distanceFade = 1.0 - (float(i) / maxSteps);

            reflectionColor = texture(screenTexture, screenPos);
            reflectionColor.a = edgeFade * distanceFade;
            break;
        }
    }

    FragColor = mix(baseColor, reflectionColor, reflectionColor.a * reflectivity);
}
