#version 330 core

layout (location = 0) in vec3 vertex;
layout (location = 7) in mat4 model;

out vec3 FragPos;

uniform mat4 camera;

void main()
{
    FragPos = vec3(model * vec4(vertex, 1.0));
    gl_Position = camera * model * vec4(vertex, 1.0);
}
