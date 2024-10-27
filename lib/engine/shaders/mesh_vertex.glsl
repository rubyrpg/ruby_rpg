#version 330 core

// <vec2 position, vec2 texCoords, vec3 normal, vec3 tangent>
layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 texCoord;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec3 tangent;
layout (location = 7) in mat4 model;

out vec2 TexCoord;
out vec3 Normal;
out vec3 Tangent;
out vec3 FragPos;

uniform mat4 camera;

void main()
{
    TexCoord = texCoord;
    mat3 normalMatrix = mat3(transpose(inverse(model)));
    Normal = normalMatrix * normal;
    Tangent = normalMatrix * tangent;
    FragPos = vec3(model * vec4(vertex, 1.0));
    gl_Position = camera * model * vec4(vertex, 1.0);
}
