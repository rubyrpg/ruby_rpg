// Order-Independent Transparency (Weighted Blended OIT)
// Include this in custom transparent fragment shaders.
//
// Usage:
//   In your fragment shader, include "oit/oit.glsl"
//
//   void main() {
//       vec3 color = /* your lighting/effect logic */;
//       float alpha = /* your alpha */;
//
//       // Optional: sample the opaque scene behind this fragment
//       vec3 background = OitSampleOpaque();               // at current pixel
//       vec3 distorted  = OitSampleOpaqueUV(uv + offset);  // with custom UV
//
//       OitOutput(color, alpha);
//   }

layout(location = 0) out vec4 OitAccumulation;
layout(location = 1) out float OitRevealage;

uniform sampler2D opaqueScene;
uniform vec2 screenSize;

// Sample the opaque scene at the current fragment's screen position
vec3 OitSampleOpaque() {
    vec2 uv = gl_FragCoord.xy / screenSize;
    return texture(opaqueScene, uv).rgb;
}

// Sample the opaque scene at a custom UV (0-1 range)
vec3 OitSampleOpaqueUV(vec2 uv) {
    return texture(opaqueScene, uv).rgb;
}

// Get the screen UV for the current fragment
vec2 OitScreenUV() {
    return gl_FragCoord.xy / screenSize;
}

// Write final color and alpha to OIT buffers.
// color: the final RGB color (after lighting, effects, etc.)
// alpha: transparency (0 = fully transparent, 1 = fully opaque)
void OitOutput(vec3 color, float alpha) {
    if (alpha < 0.01) discard;

    vec4 premultiplied = vec4(color * alpha, alpha);

    // Weight function (McGuire & Bavoil 2013)
    // Closer fragments get more weight
    float z = gl_FragCoord.z;
    float weight = clamp(pow(min(1.0, alpha * 10.0) + 0.01, 3.0) * 1e8 *
                         pow(1.0 - z * 0.9, 3.0), 1e-2, 3e3);

    OitAccumulation = vec4(premultiplied.rgb * weight, alpha * weight);
    OitRevealage = alpha;
}
