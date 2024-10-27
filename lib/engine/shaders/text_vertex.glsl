#version 330 core

// <vec3 position, vec2 texCoords>
layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 texCoords;
layout (location = 2) in int textIndex;
layout (location = 3) in vec2 offset;

uniform mat4 camera;
uniform mat4 model;

out vec2 TexCoords;

vec2 getTexCoords()
{
    int x = textIndex / 16;
    int y = textIndex % 16;
    return (vec2(x, y) + texCoords) / 16.0;
}

vec3 quadPosition()
{
    return vertex + vec3(offset.x, offset.y, 0);
}


void main()
{
    gl_Position = camera * model * vec4(quadPosition(), 1.0);
    TexCoords = getTexCoords();
}
