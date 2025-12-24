// Common lighting calculations shared by all light types

// Calculates Phong diffuse and specular contribution
// lightDir: normalized direction FROM fragment TO light
// Returns vec2(diffuse, specular)
vec2 CalcPhong(vec3 normal, vec3 lightDir, vec3 viewDir,
               float diffuseStrength, float specularStrength, float specularPower)
{
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(-viewDir, reflectDir), 0.0), specularPower);
    return vec2(diff * diffuseStrength, spec * specularStrength);
}
