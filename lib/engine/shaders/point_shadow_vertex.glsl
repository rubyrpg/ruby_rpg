#version 330 core

layout (location = 0) in vec3 vertex;
layout (location = 7) in mat4 model;

uniform mat4 lightSpaceMatrix;

out vec3 FragPos;

void main()
{
    vec4 worldPos = model * vec4(vertex, 1.0);
    FragPos = worldPos.xyz;
    gl_Position = lightSpaceMatrix * worldPos;
}
