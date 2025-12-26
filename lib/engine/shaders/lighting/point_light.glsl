// Point light structure and calculation functions

#include "lighting_common.glsl"

struct PointLight {
    vec3 position;
    float sqrRange;
    vec3 colour;
    bool castsShadows;
    int shadowLayerIndex;
    float shadowFar;
};
#define NR_POINT_LIGHTS 16
#define NR_SHADOW_CASTING_POINT_LIGHTS 4
uniform PointLight pointLights[NR_POINT_LIGHTS];
uniform samplerCubeArray pointShadowMaps;

float CalcPointShadow(PointLight light, int lightIndex, vec3 fragPos)
{
    if (!light.castsShadows) {
        return 0.0;
    }

    vec3 fragToLight = fragPos - light.position;
    float currentDepth = length(fragToLight);

    // Sample from cubemap array using vec4(direction, layerIndex)
    float closestDepth = texture(pointShadowMaps, vec4(fragToLight, float(light.shadowLayerIndex))).r;
    closestDepth *= light.shadowFar;  // Convert from [0,1] to world units

    float bias = 0.5;
    return currentDepth - bias > closestDepth ? 1.0 : 0.0;
}

vec3 CalcPointLight(PointLight light, int lightIndex, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 lightOffset = light.position - fragPos;
    float sqrDistance = dot(lightOffset, lightOffset);
    vec3 lightDir = normalize(lightOffset);

    float attenuation = light.sqrRange / sqrDistance;
    float shadow = CalcPointShadow(light, lightIndex, fragPos);

    vec2 phong = CalcPhong(normal, lightDir, viewDir, diffuseStrength, specularStrength, specularPower);
    return light.colour * (phong.x + phong.y) * attenuation * (1.0 - shadow);
}
