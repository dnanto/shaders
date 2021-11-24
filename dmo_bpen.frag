// Buffer A

#define PI 3.1415926535897932384626433
#define draw(dist, color) col = max(col, color * smoothstep(2.0 / iResolution.y, 0.0, dist))

float pendulum(float t, vec4 param) {
    // https://en.wikipedia.org/wiki/Harmonograph
    // vec4 -> (amplitude, frequency, phase, damping)
    return param.x * sin(t * param.y + param.z) * exp(-t * param.w);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.y;
    vec2 oo = iResolution.xy / iResolution.y / 2.0; // center

    vec3 col = texture(iChannel0, fragCoord / iResolution.xy).xyz;
    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0,2,4));

    float t = iTime;
    vec4 p1 = vec4(0.15, 2, 3.0 * PI / 2.0, 0.005);
    vec4 p2 = vec4(0.25, 4, PI, 0.005);
    vec4 p3 = vec4(0.15, 7, PI / 2.0, 0.0005);
    vec4 p4 = vec4(0.25, 5, PI / 2.0, 0.0015);
    vec2 point = vec2(
        pendulum(t, p1) + pendulum(t, p2),
        pendulum(t, p3) + pendulum(t, p4)
    ) + oo;

    col = draw(length(uv - point) - 0.015, rnd);

    fragColor = vec4(col, 1.0);
}

// Image

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv  = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).xyz;
    fragColor = vec4(col, 1.0);
}
