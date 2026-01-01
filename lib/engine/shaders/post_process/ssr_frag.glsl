#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D screenTexture;
uniform sampler2D depthTexture;
uniform sampler2D normalTexture;
uniform samplerCube skyboxCubemap;

uniform mat4 inverseVP;
uniform mat4 viewProj;
uniform vec3 cameraPos;

uniform int maxSteps;
uniform float maxRayDistance;
uniform float thickness;
uniform float rayOffset;
uniform float nearPlane;
uniform float farPlane;

float linearizeDepth(float d) {
    return nearPlane * farPlane / (farPlane - d * (farPlane - nearPlane));
}

vec3 worldPosFromDepth(vec2 uv, float depth) {
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 world = inverseVP * ndc;
    return world.xyz / world.w;
}

void main() {
    float depth = texture(depthTexture, TexCoords).r;
    vec4 baseColor = texture(screenTexture, TexCoords);

    if (depth >= 1.0) {
        FragColor = baseColor;
        return;
    }

    vec4 normalRough = texture(normalTexture, TexCoords);
    float roughness = normalRough.a;

    if (roughness >= 1) {
        FragColor = baseColor;
        return;
    }

    vec3 worldPos = worldPosFromDepth(TexCoords, depth);
    vec3 normal = normalize(normalRough.rgb * 2.0 - 1.0);
    vec3 viewDir = normalize(worldPos - cameraPos);
    vec3 reflectDir = reflect(viewDir, normal);

    // Project ray start/end to screen space once
    vec3 rayStart = worldPos + reflectDir * rayOffset;
    vec3 rayEnd = worldPos + reflectDir * maxRayDistance;

    vec4 clipStart = viewProj * vec4(rayStart, 1.0);
    vec4 clipEnd = viewProj * vec4(rayEnd, 1.0);

    if (clipEnd.w < 0.0) {
        float t = clipStart.w / (clipStart.w - clipEnd.w);
        clipEnd = mix(clipStart, clipEnd, t);
    }

    vec3 screenStart = clipStart.xyz / clipStart.w;
    vec3 screenEnd = clipEnd.xyz / clipEnd.w;

    screenStart.xy = screenStart.xy * 0.5 + 0.5;
    screenEnd.xy = screenEnd.xy * 0.5 + 0.5;
    screenStart.z = screenStart.z * 0.5 + 0.5;
    screenEnd.z = screenEnd.z * 0.5 + 0.5;

    // Ray march in screen space with perspective-correct depth
    float linearDepthStart = linearizeDepth(screenStart.z);
    float linearDepthEnd = linearizeDepth(screenEnd.z);

    bool hitFound = false;
    vec2 hitUV;

    for (int i = 0; i < maxSteps; i++) {
        float t = float(i) / float(maxSteps - 1);

        vec2 screenPos = mix(screenStart.xy, screenEnd.xy, t);

        if (screenPos.x < 0.0 || screenPos.x > 1.0 ||
            screenPos.y < 0.0 || screenPos.y > 1.0) {
            break;
        }

        float rayLinearDepth = (linearDepthStart * linearDepthEnd) /
                                mix(linearDepthEnd, linearDepthStart, t);

        float sceneDepthRaw = texture(depthTexture, screenPos).r;
        if (sceneDepthRaw >= 1.0) continue;

        float sceneLinearDepth = linearizeDepth(sceneDepthRaw);
        float depthDiff = rayLinearDepth - sceneLinearDepth;

        if (depthDiff > 0.0 && depthDiff < thickness) {
            hitFound = true;
            hitUV = screenPos;
            break;
        }
    }

    float reflectivity = 1.0 - roughness;

    if (hitFound) {
        vec4 reflectionColor = texture(screenTexture, hitUV);
        FragColor = mix(baseColor, reflectionColor, reflectivity);
    } else {
        vec4 skyColor = texture(skyboxCubemap, reflectDir);
        FragColor = mix(baseColor, skyColor, reflectivity);
    }
}
