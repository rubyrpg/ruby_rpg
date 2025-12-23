#version 330 core

layout (location = 0) in vec3 vertex;
layout (location = 7) in mat4 model;

uniform mat4 lightSpaceMatrix;

void main()
{
    gl_Position = lightSpaceMatrix * model * vec4(vertex, 1.0);
}
