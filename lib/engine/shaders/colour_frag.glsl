#version 330 core

out vec4 FragColour;
in vec4 ourColour;

void main()
{
    FragColour = ourColour;
}