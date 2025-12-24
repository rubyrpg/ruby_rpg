#version 330 core

in vec3 FragPos;

uniform vec3 lightPos;
uniform float farPlane;

void main()
{
    float dist = length(FragPos - lightPos);
    gl_FragDepth = dist / farPlane;
}
