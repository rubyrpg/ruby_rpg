// Lighting structures and calculation functions
// Include this file in shaders that need lighting support

struct DirectionalLight {
    vec3 direction;
    vec3 colour;
};
#define NR_DIRECTIONAL_LIGHTS 4
uniform DirectionalLight directionalLights[NR_DIRECTIONAL_LIGHTS];

struct PointLight {
    vec3 position;
    float sqrRange;
    vec3 colour;
};
#define NR_POINT_LIGHTS 16
uniform PointLight pointLights[NR_POINT_LIGHTS];

struct SpotLight {
    vec3 position;
    vec3 direction;
    float sqrRange;
    vec3 colour;
    float innerCutoff;
    float outerCutoff;
};
#define NR_SPOT_LIGHTS 8
uniform SpotLight spotLights[NR_SPOT_LIGHTS];

vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 lightOffset = light.position - fragPos;
    float sqrDistance = dot(lightOffset, lightOffset);
    vec3 lightDir = normalize(lightOffset);

    float theta = dot(lightDir, -light.direction);
    float epsilon = light.innerCutoff - light.outerCutoff;
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);

    float diff = max(dot(normal, lightDir), 0.0);

    vec3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float attenuation = light.sqrRange / sqrDistance;

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular) * attenuation * intensity;
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 lightOffset = light.position - fragPos;
    float sqrDistance = dot(lightOffset, lightOffset);
    vec3 lightDir = normalize(lightOffset);
    float diff = max(dot(normal, lightDir), 0.0);

    vec3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float attenuation = light.sqrRange / sqrDistance;

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular) * attenuation;
}

vec3 CalcDirectionalLight(DirectionalLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    float diff = max(dot(normal, -light.direction), 0.0);

    vec3 reflectDir = reflect(-light.direction, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular);
}

vec3 CalcAllLights(vec3 normal, vec3 fragPos, vec3 viewDir, vec3 ambientLight, float diffuseStrength, float specularStrength, float specularPower)
{
    vec3 result = ambientLight;

    for (int i = 0; i < NR_POINT_LIGHTS; i++) {
        if (pointLights[i].sqrRange == 0.0) break;
        result += CalcPointLight(pointLights[i], normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    for (int i = 0; i < NR_DIRECTIONAL_LIGHTS; i++) {
        if (directionalLights[i].colour == vec3(0.0)) break;
        result += CalcDirectionalLight(directionalLights[i], normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    for (int i = 0; i < NR_SPOT_LIGHTS; i++) {
        if (spotLights[i].sqrRange == 0.0) break;
        result += CalcSpotLight(spotLights[i], normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    return result;
}
