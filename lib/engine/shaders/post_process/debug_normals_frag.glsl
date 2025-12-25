#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D screenTexture;
uniform sampler2D normalTexture;

void main()
{
    vec4 normalRough = texture(normalTexture, TexCoords);
    vec3 normal = normalRough.rgb;  // already 0-1 encoded
    float roughness = normalRough.a;

    // Output: RGB = normal colors (visualizes surface orientation)
    // Blue = up, Green = forward, Red = right
    color = vec4(normal, 1.0);

    // Uncomment to visualize roughness instead:
    // color = vec4(vec3(roughness), 1.0);
}
