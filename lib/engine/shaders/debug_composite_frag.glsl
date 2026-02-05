#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform sampler2D debugTexture;
uniform vec2 texelSize; // 1.0 / textureSize

void main()
{
    // Sample center and 8 neighbors for dilation
    vec4 center = texture(debugTexture, TexCoords);

    vec4 n  = texture(debugTexture, TexCoords + vec2( 0.0,  1.0) * texelSize);
    vec4 s  = texture(debugTexture, TexCoords + vec2( 0.0, -1.0) * texelSize);
    vec4 e  = texture(debugTexture, TexCoords + vec2( 1.0,  0.0) * texelSize);
    vec4 w  = texture(debugTexture, TexCoords + vec2(-1.0,  0.0) * texelSize);
    vec4 ne = texture(debugTexture, TexCoords + vec2( 1.0,  1.0) * texelSize);
    vec4 nw = texture(debugTexture, TexCoords + vec2(-1.0,  1.0) * texelSize);
    vec4 se = texture(debugTexture, TexCoords + vec2( 1.0, -1.0) * texelSize);
    vec4 sw = texture(debugTexture, TexCoords + vec2(-1.0, -1.0) * texelSize);

    // Weighted dilation - center has full weight, neighbors contribute
    float cardinalWeight = 0.7;
    float diagonalWeight = 0.5;

    vec4 dilated = center;
    dilated = max(dilated, n * cardinalWeight);
    dilated = max(dilated, s * cardinalWeight);
    dilated = max(dilated, e * cardinalWeight);
    dilated = max(dilated, w * cardinalWeight);
    dilated = max(dilated, ne * diagonalWeight);
    dilated = max(dilated, nw * diagonalWeight);
    dilated = max(dilated, se * diagonalWeight);
    dilated = max(dilated, sw * diagonalWeight);

    FragColor = dilated;
}
