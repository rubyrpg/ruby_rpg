#version 330 core

layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 texCoord;
layout (location = 7) in mat4 model;

out vec2 TexCoords;

uniform mat4 camera;

void main()
{
    TexCoords = texCoord;
    gl_Position = camera * model * vec4(vertex, 1.0);
}
