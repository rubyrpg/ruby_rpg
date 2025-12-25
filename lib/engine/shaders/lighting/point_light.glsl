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
// TODO: Restore samplerCubeArray when using GLSL 400 - temporarily disabled for GLSL 330 compatibility
// uniform samplerCubeArray pointShadowMaps;

float CalcPointShadow(PointLight light, int lightIndex, vec3 fragPos)
{
    // Point light shadows temporarily disabled for GLSL 330 compatibility
    return 0.0;
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
