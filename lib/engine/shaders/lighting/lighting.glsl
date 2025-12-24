// Lighting - includes all light types and provides combined calculation
// Include this file in shaders that need lighting support

#include "directional_light.glsl"
#include "point_light.glsl"
#include "spot_light.glsl"

vec3 CalcAllLights(vec3 normal, vec3 fragPos, vec3 viewDir, vec3 ambientLight, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 result = ambientLight;

    for (int i = 0; i < NR_POINT_LIGHTS; i++) {
        if (pointLights[i].sqrRange == 0.0) break;
        result += CalcPointLight(pointLights[i], i, normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    for (int i = 0; i < NR_DIRECTIONAL_LIGHTS; i++) {
        if (directionalLights[i].colour == vec3(0.0)) break;
        result += CalcDirectionalLight(directionalLights[i], i, normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    for (int i = 0; i < NR_SPOT_LIGHTS; i++) {
        if (spotLights[i].sqrRange == 0.0) break;
        result += CalcSpotLight(spotLights[i], i, normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    return result;
}
