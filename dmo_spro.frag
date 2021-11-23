// Common

#define center iResolution.xy / iResolution.y / 2.0
#define radius 0.001
#define decay 0.9975

vec2 spiro(float t, float R, float k, float l) {
    // https://en.wikipedia.org/wiki/Spirograph
    return vec2(
        R * ((1.0 - k) * cos(t) + l * k * cos((1.0 - k) / k * t)),
        R * ((1.0 - k) * sin(t) - l * k * sin((1.0 - k) / k * t))
    );
}

// Buffer A

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.y;
    vec3 col = vec3(0);
    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0,2,4));

    vec2 point = spiro(iTime, 0.6, 0.7, 0.8) + center;

    /****/ if (length(uv - center) < radius) {
        col = vec3(1);
    } else if (length(uv - point ) < radius) {
        col = rnd;
    } else {
        vec2 uv = fragCoord / iResolution.xy;
        col = texture(iChannel0, uv).xyz; // mix(col, texture(iChannel0, uv).xyz, decay);
    }

    fragColor = vec4(col, 1.0);
}


// Image

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv  = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).xyz;
    fragColor = vec4(col, 1.0);
}
