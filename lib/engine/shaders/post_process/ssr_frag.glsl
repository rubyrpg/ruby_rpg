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
    float depth = texture(depthTexture, TexCoords).r;
    if (depth >= 1.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);  // Sky = black
        return;
    }

    vec4 normalRough = texture(normalTexture, TexCoords);
    float roughness = normalRough.a;
    if (roughness > 0.9) {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0);  // Matte = black
        return;
    }

    vec3 worldPos = worldPosFromDepth(TexCoords, depth);
    vec3 normal = normalize(normalRough.rgb * 2.0 - 1.0);
    vec3 viewDir = normalize(worldPos - cameraPos);
    vec3 reflectDir = reflect(viewDir, normal);

    vec3 rayPos = worldPos + reflectDir * 2.0;

    // Track previous state
    float prevDepthDiff = -1.0;
    vec2 prevScreenPos = TexCoords;
    bool hitFound = false;
    vec2 hitScreenPos;

    float maxScreenStep = 0.05;  // Max allowed screen-space jump per step

    for (int i = 0; i < int(maxSteps); i++) {
        rayPos += reflectDir * stepSize;

        bool validProj;
        vec2 screenPos = worldToScreen(rayPos, validProj);
        if (!validProj) break;

        if (screenPos.x < 0.0 || screenPos.x > 1.0 ||
            screenPos.y < 0.0 || screenPos.y > 1.0) {
            break;
        }

        // Check for screen-space jump (reject teleporting rays)
        float screenDist = length(screenPos - prevScreenPos);
        if (screenDist > maxScreenStep) {
            prevScreenPos = screenPos;
            prevDepthDiff = -1.0;  // Reset crossing detection
            continue;
        }

        float rayDepth = getDepthAt(rayPos);
        float sceneDepth = texture(depthTexture, screenPos).r;

        if (sceneDepth >= 1.0) {
            prevDepthDiff = -1.0;
            prevScreenPos = screenPos;
            continue;
        }

        float depthDiff = rayDepth - sceneDepth;

        // Only hit when crossing from in-front to behind
        if (prevDepthDiff < 0.0 && depthDiff > 0.0 && depthDiff < thickness) {
            // Verify: is the ray actually close to the geometry in WORLD space?
            vec3 hitWorldPos = worldPosFromDepth(screenPos, sceneDepth);
            float worldDist = length(rayPos - hitWorldPos);

            // Only accept if world positions are close (reject false screen-space hits)
            if (worldDist < stepSize * 3.0) {
                hitFound = true;
                hitScreenPos = screenPos;
                break;
            }
        }

        prevDepthDiff = depthDiff;
        prevScreenPos = screenPos;
    }

    vec4 baseColor = texture(screenTexture, TexCoords);

    if (hitFound) {
        vec4 reflectionColor = texture(screenTexture, hitScreenPos);
        float reflectivity = 1.0 - roughness;

        // Edge fading
        float edgeFadeX = 1.0 - pow(abs(hitScreenPos.x - 0.5) * 2.0, 2.0);
        float edgeFadeY = 1.0 - pow(abs(hitScreenPos.y - 0.5) * 2.0, 2.0);
        float edgeFade = clamp(edgeFadeX * edgeFadeY, 0.0, 1.0);

        FragColor = mix(baseColor, reflectionColor, edgeFade * reflectivity);
    } else {
        FragColor = baseColor;
    }
}
