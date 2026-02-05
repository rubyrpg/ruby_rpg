#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;

uniform mat4 camera;

out vec3 lineColor;

void main()
{
    gl_Position = camera * vec4(position, 1.0);
    lineColor = color;
}
