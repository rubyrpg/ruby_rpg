// Lighting structures and calculation functions
// Include this file in shaders that need lighting support

struct DirectionalLight {
    vec3 direction;
    vec3 colour;
    mat4 lightSpaceMatrix;
    bool castsShadows;
};
#define NR_DIRECTIONAL_LIGHTS 4
uniform DirectionalLight directionalLights[NR_DIRECTIONAL_LIGHTS];
uniform sampler2D directionalShadowMaps[NR_DIRECTIONAL_LIGHTS];  // can't be in struct in GLSL 330

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
    mat4 lightSpaceMatrix;
    bool castsShadows;
    float shadowNear;
    float shadowFar;
};
#define NR_SPOT_LIGHTS 8
uniform SpotLight spotLights[NR_SPOT_LIGHTS];
uniform sampler2D spotShadowMaps[NR_SPOT_LIGHTS];  // can't be in struct in GLSL 330

// Convert non-linear depth buffer value to linear depth
float LinearizeDepth(float depth, float near, float far)
{
    float z = depth * 2.0 - 1.0; // back to NDC
    return (2.0 * near * far) / (far + near - z * (far - near));
}

float CalcSpotShadow(SpotLight light, int lightIndex, vec3 fragPos)
{
    if (!light.castsShadows) {
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

    float closestDepth = texture(spotShadowMaps[lightIndex], projCoords.xy).r;
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

    float diff = max(dot(normal, lightDir), 0.0);

    vec3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float attenuation = light.sqrRange / sqrDistance;

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular) * attenuation * intensity * (1.0 - shadow);
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

float CalcShadow(DirectionalLight light, int lightIndex, vec3 fragPos)
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

    float closestDepth = texture(directionalShadowMaps[lightIndex], projCoords.xy).r;
    float currentDepth = projCoords.z;
    float bias = 0.005;

    return currentDepth - bias > closestDepth ? 1.0 : 0.0;
}

vec3 CalcDirectionalLight(DirectionalLight light, int lightIndex, vec3 normal, vec3 fragPos, vec3 viewDir, float diffuseStrength, float specularStrength, float specularPower)
{
    float shadow = CalcShadow(light, lightIndex, fragPos);

    float diff = max(dot(normal, -light.direction), 0.0);

    vec3 reflectDir = reflect(-light.direction, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular) * (1.0 - shadow);
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
        result += CalcDirectionalLight(directionalLights[i], i, normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    for (int i = 0; i < NR_SPOT_LIGHTS; i++) {
        if (spotLights[i].sqrRange == 0.0) break;
        result += CalcSpotLight(spotLights[i], i, normal, fragPos, viewDir, diffuseStrength, specularStrength, specularPower);
    }

    return result;
}
