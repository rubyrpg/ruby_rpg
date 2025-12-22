#version 330 core

layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 texCoord;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec3 tangent;
layout (location = 7) in mat4 model;

uniform vec3 colour;
uniform mat4 camera;

out vec4 ourColour;

void main()
{
    gl_Position = camera * model * vec4(vertex, 1.0);
    ourColour = vec4(colour, 1.0);
}