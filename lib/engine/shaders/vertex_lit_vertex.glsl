#version 330 core

// <vec2 position, vec2 texCoords, vec3 normal, vec3 tangent>
layout (location = 0) in vec3 vertex;
layout (location = 2) in vec3 normal;
layout (location = 4) in vec3 diffuse;
layout (location = 5) in vec3 specular;
layout (location = 6) in vec3 albedo;
layout (location = 7) in mat4 model;

out vec3 Normal;
out vec3 FragPos;
out vec3 Diffuse;
out vec3 Specular;
out vec3 Albedo;

uniform mat4 camera;

void main()
{
    mat3 normalMatrix = mat3(transpose(inverse(model)));
    Normal = normalMatrix * normal;
    FragPos = vec3(model * vec4(vertex, 1.0));
    gl_Position = camera * model * vec4(vertex, 1.0);
    Diffuse = diffuse;
    Specular = specular;
    Albedo = albedo;
}
