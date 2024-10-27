#version 330 core

in vec3 FragPos;
out vec4 color;

void main()
{
    vec4 ground = vec4(0.541176, 0.709804, 0.286275, 1);
    vec4 sky = vec4(0.2, 0.6, 0.8, 1);
    float mixFactor = clamp(FragPos.y / 2.0, 0.0, 1.0);
    color = mix(ground, sky, mixFactor);
}
