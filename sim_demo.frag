// Common

#define N         25
#define G         0.00025
#define SOFTENING 0.01

// Buffer A

float random(vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 force_gravity(int i, vec2 pos, float softening) {
    vec2 f = vec2(0);
    for (int j = 0; j < N; j++) {
        if (i != j) {
            vec4 obj = texelFetch(iChannel0, ivec2(j, 0), 0);
            vec2 r = obj.xy - pos;
            f += (1.0 * r) / pow(pow(length(r), 2.0) + softening * softening, 1.5);
        }
    }
    return G * 1.0 * f;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord;
    ivec2 iv = ivec2(uv);

    vec4 frag;
    if (iFrame < 60) {
        uv += vec2(random(vec2(iTime)), random(vec2(iTime * iTime)));
        frag = vec4(
            random(uv.xx), random(uv.xy), // position
            random(uv.yx), random(uv.yy)  // velocity
        );
        frag.zw *= 0.0025;
    } else {
        vec4 obj = vec4(0);
        if (iv.x < N && iv.y == 0) {
            obj = texelFetch(iChannel0, ivec2(uv), 0);
            /*
                f = force(pos)
                fpos = pos + vel * dt + 0.5 * f * dt ** 2
                fvel = vel + 0.5 * (f + force(fpos)) * dt
             */
            vec2 f1 = force_gravity(iv.x, obj.xy, SOFTENING);
            obj.xy = obj.xy + obj.zw * iTimeDelta + 0.5 * f1 * iTimeDelta * iTimeDelta;
            vec2 f2 = force_gravity(iv.x, obj.xy, SOFTENING);
            obj.zw = obj.zw + 0.5 * (f1 + f2) * iTimeDelta;

        }
        frag = obj;
    }

    fragColor = frag;
}

// Image

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // output Buffer A
    vec2 uv = fragCoord/iResolution.xy;

    vec3 col = vec3(0);
    for (int i = 0; i < N; i++) {
        vec4 data = texelFetch(iChannel0, ivec2(i, 0), 0);
        if (distance(uv, data.xy) < 0.010) {
            col = data.xyy;
        }
    }

    fragColor = vec4(col, 1);
}
