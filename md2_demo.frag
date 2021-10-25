// Common

/////// buffer data channel row index: position & velocity
#define IPOS 0
/////// buffer data channel row index: properties (mass, radius, & collision)
#define IPRP 1
/////// buffer data channel row index: end of data
#define IEND 2
/////// number of particles
#define N 1280
/////// maximum particle mass
#define MPMASS 1.0
/////// maximum particle radius
#define MPRADI 0.015
/////// maximum particle velocity
#define MPVELO 0.25

float random(vec2 seed) {
    // https://thebookofshaders.com/10/
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 random3(vec2 seed) {
    return vec3(random(seed.xy), random(seed.yx), random(seed.xx));
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
                fcol = vec4(random3(uv.xy + iDate.xy + iTime).xy, 0, 0);
                vec2 vel = random3(uv.yx + iDate.xy + iTime).xy;
                vel.x *= random(uv.xy + iDate.xy + iTime) < 0.5 ? -1.0 : +1.0;
                vel.y *= random(uv.yx + iDate.xy + iTime) < 0.5 ? -1.0 : +1.0;
                fcol.zw = vel * MPVELO;
            } else if (iv.y == IPRP) {
                fcol.x = MPMASS * random(uv.xy + iDate.xy + iTime); // mass
                fcol.y = fcol.x / MPMASS * MPRADI;                  // radius
            }
        } else {
            vec4 motion1 = texelFetch(iChannel0, ivec2(iv.x, IPOS), 0);
            vec2 pos1 = motion1.xy;
            vec2 vel1 = motion1.zw;
            vec4 prop1 = texelFetch(iChannel0, ivec2(iv.x, IPRP), 0);
            float mass1 = prop1.x;
            float radius1 = prop1.y;

            bool cll = false;
            for (int j = 0; j < N; j++) {
                if (iv.x != j) {
                    vec4 motion2 = texelFetch(iChannel0, ivec2(j, IPOS), 0);
                    vec2 pos2 = motion2.xy;
                    vec2 vel2 = motion2.zw;
                    vec4 prop2 = texelFetch(iChannel0, ivec2(j, IPRP), 0);
                    float mass2 = prop2.x;
                    float radius2 = prop2.y;
                    float d = distance(pos1, pos2);
                    if (d < radius1 + radius2) {
                        vec2 n = normalize(pos1 - pos2);
                        pos1 += n * (radius1 + radius2 - d);
                        // https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects
                        vel1 -= (2.0 * mass2 / (mass1 + mass2)) * (dot(vel1 - vel2, pos1 - pos2) / length(pos1 - pos2)) * (pos1 - pos2);
                        // https://en.wikipedia.org/wiki/Specular_reflection#Vector_formulation
                        vel1 -= 2.0 * dot(vel1, n) * n;
                        cll = true;
                        break;
                    }
                }
            }

            pos1 += vel1 * iTimeDelta;

            /****/ if (iv.y == IPOS) {
                fcol = vec4(pos1, vel1);
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
    vec2 uv = fragCoord / iResolution.xy;

    vec3 col = vec3(0);
    for (int j = 0; j < N; j++) {
        vec4 motion = texelFetch(iChannel0, ivec2(j, IPOS), 0);
        vec4 prop = texelFetch(iChannel0, ivec2(j, IPRP), 0);
        float dist = distance(uv, motion.xy);
        if (dist < prop.y) {
            col = vec3(0, 1, 1);
            if (dist < prop.y - prop.y * 0.075) {
                float speed = clamp(length(motion.zw) / length(vec2(MPVELO, MPVELO)), 0.25, 1.0);
                col = prop.z == 1.0 ? vec3(speed, 0, 0) : vec3(0, speed, 0);
            }
        }
    }

    fragColor = vec4(col, 1);
}
