#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D screenTexture;
uniform sampler2D ssrTexture;

void main() {
    vec4 sceneColor = texture(screenTexture, TexCoords);
    vec4 ssr = texture(ssrTexture, TexCoords);

    // ssr.rgb = reflection color, ssr.a = reflectivity
    vec3 finalColor = mix(sceneColor.rgb, ssr.rgb, ssr.a);
    FragColor = vec4(finalColor, sceneColor.a);
}
