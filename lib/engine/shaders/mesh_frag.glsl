#version 330 core

in vec2 TexCoord;
in vec3 Normal;
in vec3 Tangent;
in vec3 FragPos;

out vec4 color;

uniform sampler2D image;
uniform sampler2D normalMap;
uniform vec3 cameraPos;
uniform float diffuseStrength;
uniform float specularStrength;
uniform float specularPower;
uniform vec3 ambientLight;

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

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
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

vec3 CalcDirectionalLight(DirectionalLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    float diff = max(dot(normal, -light.direction), 0.0);

    vec3 reflectDir = reflect(-light.direction, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);

    float diffuse = diff * diffuseStrength;
    float specular = spec * specularStrength;

    return light.colour * (diffuse + specular);
}

void main()
{
    vec3 sampledNormal = texture(normalMap, TexCoord).rgb * 2.0 - 1.0;
    if ( sampledNormal.r + sampledNormal.g + sampledNormal.b <= 0)
    {
        sampledNormal = vec3(0.0, 0.0, 1.0);
    }
    vec3 n = normalize(Normal);
    vec3 t = normalize(Tangent);
    vec3 norm = n;
    if ( length(t) > 0.0 )
    {
        vec3 b = cross(t, n);
        mat3 TBN = mat3(t, b, n);
        norm = normalize(TBN * normalize(sampledNormal));
    }
    vec3 viewDir = normalize(cameraPos - FragPos);

    vec3 result = ambientLight;

    for (int i = 0; i < NR_POINT_LIGHTS; i++) {
        if (pointLights[i].sqrRange == 0.0)
        {
            break;
        }
        result += CalcPointLight(pointLights[i], norm, FragPos, viewDir);
    }

    for (int i = 0; i < NR_DIRECTIONAL_LIGHTS; i++) {
        if (directionalLights[i].colour == vec3(0.0))
        {
            break;
        }
        result += CalcDirectionalLight(directionalLights[i], norm, FragPos, viewDir);
    }

    vec4 tex = texture(image, TexCoord);
    color = tex * vec4(result, 1.0);
}
