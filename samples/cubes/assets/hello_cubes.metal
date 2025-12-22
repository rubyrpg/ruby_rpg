#include <metal_stdlib>
using namespace metal;

// Uniforms structure - matches the order we pack in Ruby
struct Uniforms {
    float u_time;
};

// --- Simple Hash-Based Noise Functions ---
// 1D hash function
float hash1D(int n) {
    n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return float(n & 0x7fffffff) / float(0x7fffffff);
}

// 2D hash function
float hash2D(int2 p) {
    int n = p.x * 73856093 + p.y * 19349663;
    n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return float(n & 0x7fffffff) / float(0x7fffffff);
}

// Simple 2D Value Noise
float valueNoise2D(float2 p) {
    int2 ip = int2(floor(p));
    float2 fp = fract(p);

    float v00 = hash2D(ip);
    float v10 = hash2D(ip + int2(1, 0));
    float v01 = hash2D(ip + int2(0, 1));
    float v11 = hash2D(ip + int2(1, 1));

    // Smooth interpolation
    float2 smooth_p = fp * fp * fp * (fp * (fp * 6.0 - 15.0) + 10.0);

    float interp_x1 = mix(v00, v10, smooth_p.x);
    float interp_x2 = mix(v01, v11, smooth_p.x);

    return mix(interp_x1, interp_x2, smooth_p.y);
}

// Fractional Brownian Motion
float fbm(float2 p) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    const int num_octaves = 5;

    for (int i = 0; i < num_octaves; ++i) {
        value += valueNoise2D(p * frequency) * amplitude;
        frequency *= 2.0;
        amplitude *= 0.5;
        p += float2(100.0, 100.0);
    }
    return value;
}

kernel void computeMain(
    texture2d<float, access::write> outputColor [[texture(0)]],
    texture2d<float, access::write> outputNormal [[texture(1)]],
    constant Uniforms& uniforms [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    // Image dimensions
    float2 image_size = float2(outputColor.get_width(), outputColor.get_height());

    // Check bounds
    if (gid.x >= uint(image_size.x) || gid.y >= uint(image_size.y)) {
        return;
    }

    // Normalized coordinates (0.0 to 1.0)
    float2 uv = float2(gid) / image_size;

    // --- Animated Noise Generation ---
    float pattern_scale = 30.0;
    float2 noise_coords = uv * pattern_scale;

    float flow_speed_x = 0.2;
    float flow_speed_y = 0.3;
    float2 animated_noise_coords = noise_coords + float2(uniforms.u_time * flow_speed_x, uniforms.u_time * flow_speed_y);

    float noise_value = fbm(animated_noise_coords);

    // --- Color Mapping (Lava Gradient) ---
    float4 color1 = float4(0.0, 0.0, 0.0, 1.0); // Black
    float4 color2 = float4(0.5, 0.1, 0.0, 1.0); // Dark Red
    float4 color3 = float4(0.9, 0.4, 0.1, 1.0); // Orange
    float4 color4 = float4(1.0, 0.8, 0.0, 1.0); // Yellow

    float4 output_color;
    output_color = mix(color1, color2, smoothstep(0.0, 0.3, noise_value));
    output_color = mix(output_color, color3, smoothstep(0.2, 0.5, noise_value));
    output_color = mix(output_color, color4, smoothstep(0.4, 0.7, noise_value));

    outputColor.write(output_color, gid);

    // --- Normal Map Calculation ---
    float2 epsilon = float2(1.0 / image_size.x, 1.0 / image_size.y) * 0.5;

    float noise_dx = fbm(animated_noise_coords + float2(epsilon.x * pattern_scale, 0.0));
    float noise_dy = fbm(animated_noise_coords + float2(0.0, epsilon.y * pattern_scale));

    float gradient_x = noise_dx - noise_value;
    float gradient_y = noise_dy - noise_value;

    float bump_strength = 10.0;
    float3 normal_vector = normalize(float3(
        gradient_x * bump_strength,
        gradient_y * bump_strength,
        1.0
    ));

    // Map from [-1,1] to [0,1]
    float4 normal_output = float4(normal_vector * 0.5 + 0.5, 1.0);

    outputNormal.write(normal_output, gid);
}
