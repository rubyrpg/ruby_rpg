#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform vec3 horizonColour;
uniform vec3 skyColour;
uniform int faceIndex;

vec3 getDirection(vec2 uv, int face) {
    vec2 st = uv * 2.0 - 1.0;
    vec3 dir;

    switch(face) {
        case 0: dir = vec3( 1.0, -st.y, -st.x); break;  // +X
        case 1: dir = vec3(-1.0, -st.y,  st.x); break;  // -X
        case 2: dir = vec3( st.x,  1.0,  st.y); break;  // +Y
        case 3: dir = vec3( st.x, -1.0, -st.y); break;  // -Y
        case 4: dir = vec3( st.x, -st.y,  1.0); break;  // +Z
        case 5: dir = vec3(-st.x, -st.y, -1.0); break;  // -Z
        default: dir = vec3(0.0, 1.0, 0.0); break;
    }

    return normalize(dir);
}

void main() {
    vec3 dir = getDirection(TexCoords, faceIndex);

    // Gradient based on Y component of direction
    float mixFactor = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 color = mix(horizonColour, skyColour, mixFactor);

    FragColor = vec4(color, 1.0);
}
