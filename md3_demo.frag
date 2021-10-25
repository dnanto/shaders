// Common

/////// buffer data row index: position
#define IPOS 0
/////// buffer data row index: velocity
#define IVEL 1
/////// buffer data row index: end of data
#define IEND 2
/////// number of particles
#define N 1280
/////// particle mass
#define M 0.005
/////// gravitational constant
#define G 1.000
/////// softening
#define S 0.100
/////// boundary potential factor
#define K 25.0
/////// boundary potential sphere position
#define POSB vec3(0.5)
/////// boundary potential sphere radius
#define RADB 0.40
/////// initialization sphere radius
#define RADI 0.20
/////// particle radius
#define RADP 0.005

float random(vec2 seed) {
    // https://thebookofshaders.com/10/
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 random3(vec2 seed) {
    return vec3(random(seed.xy), random(seed.yx), random(seed.xx));
}

vec3 force_gravity(ivec2 i, vec3 pos, sampler2D iChannel) {
    // https://developer.nvidia.com/gpugems/gpugems3/part-v-physics-simulation/chapter-31-fast-n-body-simulation-cuda
    vec3 f = vec3(0);
    for (int j = 0; j < N; j++) {
        vec3 r = texelFetch(iChannel, ivec2(j, IPOS), 0).xyz - pos.xyz;
        f += M * r / pow(pow(length(r), 2.0) + S * S, 1.5);
    }
    return G * M * f;
}

vec3 force_boundary(vec3 pos) {
    float r = distance(pos, POSB);
    return r >= RADB ? -2.0 * K * (r - RADB) * (pos - vec3(0.5)) : vec3(0);
}

// Buffer A

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2  uv = fragCoord;
    ivec2 iv = ivec2(uv);

    vec4 fcol = vec4(0);
    if (iv.x < N && iv.y < IEND) {
        if (iFrame == 0) {
            // initialize
            if (iv.y == IPOS) {
                // https://math.stackexchange.com/a/1585996
                vec3 pos = 1.0 - 2.0 * random3(uv + iTime);
                pos = normalize(pos) * RADI + vec3(0.5);
                fcol = vec4(pos, 0);
            }
        } else {
            // verlet integration
            // fpos = pos + vel * dt + 0.5 * force(pos) * dt ** 2
            // fvel = vel + 0.5 * (f + force(fpos)) * dt
            vec3 pos = texelFetch(iChannel0, ivec2(iv.x, IPOS), 0).xyz;
            vec3 vel = texelFetch(iChannel0, ivec2(iv.x, IVEL), 0).xyz;
            vec3 ff1 = force_gravity(iv, pos, iChannel0) + force_boundary(pos);
            pos += vel * iTimeDelta + 0.5 * ff1 * iTimeDelta * iTimeDelta;
            /****/ if (iv.y == IPOS) {
                fcol = vec4(pos, 0);
            } else if (iv.y == IVEL) {
                vec3 ff2 = force_gravity(iv, pos, iChannel0) + force_boundary(pos);
                vel += 0.5 * (ff1 + ff2) * iTimeDelta;
                fcol = vec4(vel, 0);
            }
        }
    }

    fragColor = fcol;
}

// Image

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    vec3 col = vec3(0);
    for (int i = 0; i < N; i++) {
        vec4 pos = texelFetch(iChannel0, ivec2(i, IPOS), 0);
        if (distance(uv, pos.xy) < RADP) {
            col = 1.0 - pos.zzz;
        }
    }

    float d = distance(uv, vec2(0.5));
    if (RADI - RADP <= d && d <= RADI + RADP) col = mix(col, vec3(0, 1, 1), 0.5);
    if (RADB - RADP <= d && d <= RADB + RADP) col = mix(col, vec3(1, 0, 1), 0.5);

    fragColor = vec4(col, 1);
}
