#version 330 core

out vec4 color;

in vec2 TexCoords;

uniform sampler2D fontTexture;

void main()
{
    vec4 textureColor = texture(fontTexture, TexCoords);
    if(textureColor.a < 0.1)
        discard;
    color = vec4(1.0, 1.0, 1.0, textureColor.a);
}
