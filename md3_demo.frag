// Common

/////// buffer data row index: position
#define IPOS 0
/////// buffer data row index: velocity
#define IVEL 1
/////// buffer data channel row index: properties (mass, radius, & collision)
#define IPRP 2
/////// buffer data row index: end of data
#define IEND 3
/////// number of particles
#define N 1280 / 16
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
/////// maximum particle mass
#define MPMASS 100.0
/////// maximum particle radius
#define MPRADI 0.015
/////// maximum particle initial velocity
#define MPVELO 0.050

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

vec3 forces(ivec2 iv, vec3 pos, sampler2D iChannel) {
    return force_gravity(iv, pos, iChannel) + force_boundary(pos);
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
            /****/ if (iv.y == IPOS) {
                // https://math.stackexchange.com/a/1585996
                vec3 pos = 1.0 - 2.0 * random3(uv + iTime);
                pos = normalize(pos) * RADI + vec3(0.5);
                fcol = vec4(pos, 0);
            } else if (iv.y == IVEL) {
                vec3 vel = random3(uv.yx + iDate.xy + iTime).xyz;
                vel.x *= random(uv.xy + iDate.xy + iTime) < 0.5 ? -1.0 : +1.0;
                vel.y *= random(uv.yx + iDate.xy + iTime) < 0.5 ? -1.0 : +1.0;
                vel.z *= random(uv.yy + iDate.xy + iTime) < 0.5 ? -1.0 : +1.0;
                fcol.xyz = vel * MPVELO;
            } else if (iv.y == IPRP) {
                fcol.x = MPMASS * random(uv.xy + iDate.xy + iTime); // mass
                fcol.y = fcol.x / MPMASS * MPRADI;                  // radius
            }
        } else {
            // collisions
            bool cll = false;
            vec3 pos1 = texelFetch(iChannel0, ivec2(iv.x, IPOS), 0).xyz;
            vec3 vel1 = texelFetch(iChannel0, ivec2(iv.x, IVEL), 0).xyz;
            vec4 prop1 = texelFetch(iChannel0, ivec2(iv.x, IPRP), 0);
            float mass1 = prop1.x;
            float radius1 = prop1.y;
            for (int j = 0; j < N; j++) {
                if (iv.x != j) {
                    vec3 pos2 = texelFetch(iChannel0, ivec2(j, IPOS), 0).xyz;
                    vec3 vel2 = texelFetch(iChannel0, ivec2(j, IVEL), 0).xyz;
                    vec4 prop2 = texelFetch(iChannel0, ivec2(j, IPRP), 0);
                    float mass2 = prop2.x;
                    float radius2 = prop2.y;
                    float d = distance(pos1, pos2);
                    if (d < radius1 + radius2) {
                        vec3 n = normalize(pos1 - pos2);
                        pos1 += n * (radius1 + radius2 - d);
                        if (dot(pos2 - pos1, vel1) > 0.0) {
                            // https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects
                            vel1 -= (2.0 * mass2 / (mass1 + mass2)) * (dot(vel1 - vel2, pos1 - pos2) / length(pos1 - pos2)) * (pos1 - pos2);
                            // https://en.wikipedia.org/wiki/Specular_reflection#Vector_formulation
                            vel1 -= 2.0 * dot(vel1, n) * n;
                        }
                        cll = true;
                        break;
                    }
                }
            }
            // potential fields
            // https://en.wikipedia.org/wiki/Verlet_integration
            // fpos = pos + vel * dt + 0.5 * forces(pos) * dt ** 2
            // fvel = vel + 0.5 * (f + forces(fpos)) * dt
            vec3 pos = pos1;
            vec3 vel = vel1;
            vec3 ff1 = forces(iv, pos, iChannel0);
            pos += vel * iTimeDelta + 0.5 * ff1 * iTimeDelta * iTimeDelta;
            /****/ if (iv.y == IPOS) {
                fcol = vec4(pos, 0);
            } else if (iv.y == IVEL) {
                vel += 0.5 * (ff1 + forces(iv, pos, iChannel0)) * iTimeDelta;
                fcol = vec4(vel, 0);
            } else if (iv.y == IPRP) {
                fcol = vec4(prop1.x, prop1.y, int(cll), 0);
            }
        }
    }

    fragColor = fcol;
}

// Image

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.y;
    uv.x -= (iResolution.x / iResolution.y - 1.0) / 2.0;

    iResolution.x / iResolution.y / 2.0;

    vec3 col = vec3(0);
    for (int j = 0; j < N; j++) {
        vec4 pos = texelFetch(iChannel0, ivec2(j, IPOS), 0);
        vec4 prop = texelFetch(iChannel0, ivec2(j, IPRP), 0);
        if (distance(uv, pos.xy) < prop.y) {
            col = 1.0 - pos.zzz;
            col = prop.z == 1.0 ? mix(col, vec3(1, 0, 0), 1.0) : col;
        }
    }

    float d = distance(uv, vec2(0.5));
    if (RADI - RADP <= d && d <= RADI + RADP) col = mix(col, vec3(0, 1, 1), 0.5);
    if (RADB - RADP <= d && d <= RADB + RADP) col = mix(col, vec3(1, 0, 1), 0.5);

    fragColor = vec4(col, 1);
}
