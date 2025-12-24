#version 400 core

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

#include "lighting.glsl"

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

    vec3 result = CalcAllLights(norm, FragPos, viewDir, ambientLight, diffuseStrength, specularStrength, specularPower);

    vec4 tex = texture(image, TexCoord);
    color = tex * vec4(result, 1.0);
}
