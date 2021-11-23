// Common

vec2 spiro(float t, float R, float k, float l) {
    // https://en.wikipedia.org/wiki/Spirograph
    return vec2(
        R * ((1.0 - k) * cos(t) + l * k * cos((1.0 - k) / k * t)),
        R * ((1.0 - k) * sin(t) - l * k * sin((1.0 - k) / k * t))
    );
}

float udSegment(in vec2 p, in vec2 a, in vec2 b) {
    // https://www.shadertoy.com/view/3tdSDj
    vec2 ba = b - a;
    vec2 pa = p - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - h * ba);
}

// Buffer A

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.y;
    vec2 center = iResolution.xy / iResolution.y / 2.0;
    vec3 col = vec3(0);
    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0,2,4));

    // https://en.wikipedia.org/wiki/Spirograph
    float R = 0.5;                                     // outer circle radius
    float l = 0.7;                                     // dimensionless l parameter = rho / r
    float k = 0.6;                                     // dimensionless k parameter = r   / R
    float t = iTime;                                   // outer circle tangent point rotation angle
    float r = k * R;                                   // inner circle radius
    float rho = l * r;                                 // distance from inner circle center to the pen
    float tp = -((R - r) / r) * t;                     // inner circle tangent point rotation angle
    vec2 pc = (R - r) * vec2(cos(t), sin(t)) + center; // inner circle center
    vec2 A = rho * vec2(cos(tp), sin(tp)) + pc;        // pen coordinate
    vec2 point = spiro(iTime, R, k, l) + center;       // also pen coordinate

    /****/ if (length(uv - center) < 0.005) {
        col = vec3(1);
    } else if (length(uv - point ) < 0.005) {
        col = rnd;
    } else if (length(uv - point ) < 0.005 * 2.0) {
        col = vec3(1);
    } else if (udSegment(uv, A, pc) < 0.0005) {
        col = vec3(1);
    } else if (r - 0.0005 < length(uv - pc) && length(uv - pc) < r + 0.0005) {
        col = rnd;
    } else if (R - 0.0025 < length(uv - center) && length(uv - center) < R + 0.0025) {
        col = vec3(1);
    } else {
        vec2 uv = fragCoord / iResolution.xy;
        col = mix(col, texture(iChannel0, uv).xyz, 0.9995);
    }

    fragColor = vec4(col, 1.0);
}

// Image

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv  = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).xyz;
    fragColor = vec4(col, 1.0);
}
