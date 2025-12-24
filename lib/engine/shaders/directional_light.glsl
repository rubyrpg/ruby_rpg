// Directional light structure and calculation functions

struct DirectionalLight {
    vec3 direction;
    vec3 colour;
    mat4 lightSpaceMatrix;
    bool castsShadows;
};
#define NR_DIRECTIONAL_LIGHTS 4
uniform DirectionalLight directionalLights[NR_DIRECTIONAL_LIGHTS];
uniform sampler2DArray directionalShadowMaps;

float CalcDirectionalShadow(DirectionalLight light, int lightIndex, vec3 fragPos)
{
    if (!light.castsShadows) {
        return 0.0;
    }

    vec4 fragPosLightSpace = light.lightSpaceMatrix * vec4(fragPos, 1.0);
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;

    // Fragment is beyond the shadow map frustum
    if (projCoords.z > 1.0) {
        return 0.0;
    }

    float closestDepth = texture(directionalShadowMaps, vec3(projCoords.xy, float(lightIndex))).r;
    float currentDepth = projCoords.z;
    float bias = 0.005;

    return currentDepth - bias > closestDepth ? 1.0 : 0.0;
}

vec3 CalcDirectionalLight(DirectionalLight light, int lightIndex, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    float shadow = CalcDirectionalShadow(light, lightIndex, fragPos);

    float diff = max(dot(normal, -light.direction), 0.0);

    vec3 reflectDir = reflect(-light.direction, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular) * (1.0 - shadow);
}
