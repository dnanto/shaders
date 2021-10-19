// Common

#define N 100

// Buffer A

float random(vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    vec4 frag;
    if (iFrame < 60) {
        uv += vec2(random(vec2(iTime)), random(vec2(iTime*iTime)));
        frag = vec4(
            random(uv.xx), random(uv.xy), // position
            random(uv.yx), random(uv.yy)  // velocity
        );
    } else {
        frag = texture(iChannel0, uv);
    }

    fragColor = frag;
}

// Image

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // output Buffer A
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col = vec3(0);
    for (int i = 0; i < N; i++) {
        vec4 data = texture(iChannel0, vec2(float(i) / iResolution.x, 0));
        if (distance(uv, data.xy) < 0.010)
            col = vec3(data.xyz);
    }

    fragColor =  vec4(col, 1);
}
