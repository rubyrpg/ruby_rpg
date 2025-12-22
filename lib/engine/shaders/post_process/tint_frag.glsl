#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform vec4 tintColor; // rgba, alpha controls intensity

void main()
{
    vec4 texColor = texture(screenTexture, TexCoords);
    vec3 tinted = mix(texColor.rgb, texColor.rgb * tintColor.rgb, tintColor.a);
    color = vec4(tinted, texColor.a);
}
