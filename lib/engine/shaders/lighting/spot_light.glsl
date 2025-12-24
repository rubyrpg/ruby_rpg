// Spot light structure and calculation functions

#include "lighting_common.glsl"

struct SpotLight {
    vec3 position;
    vec3 direction;
    float sqrRange;
    vec3 colour;
    float innerCutoff;
    float outerCutoff;
    mat4 lightSpaceMatrix;
    bool castsShadows;
    float shadowNear;
    float shadowFar;
};
#define NR_SPOT_LIGHTS 8
#define NR_SHADOW_CASTING_SPOT_LIGHTS 4
uniform SpotLight spotLights[NR_SPOT_LIGHTS];
uniform sampler2DArray spotShadowMaps;

// Convert non-linear depth buffer value to linear depth
float LinearizeDepth(float depth, float near, float far)
{
    float z = depth * 2.0 - 1.0; // back to NDC
    return (2.0 * near * far) / (far + near - z * (far - near));
}

float CalcSpotShadow(SpotLight light, int lightIndex, vec3 fragPos)
{
    if (!light.castsShadows || lightIndex >= NR_SHADOW_CASTING_SPOT_LIGHTS) {
        return 0.0;
    }

    vec4 fragPosLightSpace = light.lightSpaceMatrix * vec4(fragPos, 1.0);

    // Point is behind the light
    if (fragPosLightSpace.w <= 0.0) {
        return 0.0;
    }

    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;

    // Fragment is outside the shadow map frustum
    if (projCoords.z > 1.0 || projCoords.z < 0.0 ||
        projCoords.x < 0.0 || projCoords.x > 1.0 ||
        projCoords.y < 0.0 || projCoords.y > 1.0) {
        return 0.0;
    }

    float closestDepth = texture(spotShadowMaps, vec3(projCoords.xy, float(lightIndex))).r;
    float currentDepth = projCoords.z;

    // Convert to linear depth for more stable comparison
    float near = light.shadowNear;
    float far = light.shadowFar;
    float linearClosest = LinearizeDepth(closestDepth, near, far);
    float linearCurrent = LinearizeDepth(currentDepth, near, far);

    float bias = 0.5; // bias in world units
    return linearCurrent - bias > linearClosest ? 1.0 : 0.0;
}

vec3 CalcSpotLight(SpotLight light, int lightIndex, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 lightOffset = light.position - fragPos;
    float sqrDistance = dot(lightOffset, lightOffset);
    vec3 lightDir = normalize(lightOffset);

    float theta = dot(lightDir, -light.direction);
    float epsilon = light.innerCutoff - light.outerCutoff;
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);

    float shadow = CalcSpotShadow(light, lightIndex, fragPos);
    float attenuation = light.sqrRange / sqrDistance;

    vec2 phong = CalcPhong(normal, lightDir, viewDir, diffuseStrength, specularStrength, specularPower);
    return light.colour * (phong.x + phong.y) * attenuation * intensity * (1.0 - shadow);
}
