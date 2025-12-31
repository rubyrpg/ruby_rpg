#version 330 core

in vec2 TexCoords;
out vec4 FragColor;

uniform vec3 groundColour = vec3(0.2, 0.2, 0.2);  // neutral grey
uniform vec3 horizonColour = vec3(0.7, 0.8, 0.9); // light hazy blue
uniform vec3 skyColour = vec3(0.3, 0.5, 0.8);     // deeper blue
uniform float groundY = -0.1;   // ground gradient ends here
uniform float horizonY = 0;  // horizon line
uniform float skyY = 0.2;       // sky gradient completes here
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

    vec3 color;
    if (dir.y >= horizonY) {
        // Above horizon: blend horizon -> sky
        float mixFactor = clamp((dir.y - horizonY) / (skyY - horizonY), 0.0, 1.0);
        color = mix(horizonColour, skyColour, mixFactor);
    } else {
        // Below horizon: blend ground -> horizon
        float mixFactor = clamp((dir.y - groundY) / (horizonY - groundY), 0.0, 1.0);
        color = mix(groundColour, horizonColour, mixFactor);
    }

    FragColor = vec4(color, 1.0);
}
