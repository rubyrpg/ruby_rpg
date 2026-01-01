#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D screenTexture;
uniform sampler2D ssaoTexture;

void main() {
    vec4 sceneColor = texture(screenTexture, TexCoords);
    float ao = texture(ssaoTexture, TexCoords).r;

    // Multiply scene color by ambient occlusion
    FragColor = vec4(sceneColor.rgb * ao, sceneColor.a);
}
