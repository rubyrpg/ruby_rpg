#version 330 core
layout (location = 0) in vec3 aPos;

uniform vec3 colour;
out vec4 ourColour;

uniform mat4 camera;
uniform mat4 model;

void main()
{
    gl_Position = camera * model * vec4(aPos, 1.0);
    ourColour = vec4(colour, 1.0);
}