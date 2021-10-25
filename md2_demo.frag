// Common

/////// buffer data channel row index: position
#define IPOS 0
/////// buffer data channel row index: velocity
#define IVEL 1
/////// buffer data channel row index: collision
#define ICOL 2
/////// buffer data channel row index: end of data
#define IEND 3
/////// number of particles
#define N 1280
/////// particle mass
#define M 1.0
/////// particle radius
#define RADP 0.005

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
                fcol = vec4(random3(uv.xy + iTime).xy, 0, 0);
                /*
                    float n = ceil(sqrt(float(N)));
                    float c = mod(float(iv.x), n) / n;
                    float r = float(iv.x) / n / n;
                    fcol = vec4(c, r, 0, 0);
                 */
            } else if (iv.y == IVEL) {
                vec2 vel = random3(uv.yx + iTime).xy;
                vel.x *= random(uv.xy + iTime) > 0.5 ? -1.0 : +1.0;
                vel.y *= random(uv.yx + iTime) > 0.5 ? -1.0 : +1.0;
                fcol = vec4(vel * 0.25, 0, 0);
            }
        } else {
            vec2 pos = texelFetch(iChannel0, ivec2(iv.x, IPOS), 0).xy;
            vec2 vel = texelFetch(iChannel0, ivec2(iv.x, IVEL), 0).xy;

            bool cll = false;
            for (int j = 0; j < N; j++) {
                if (iv.x != j) {
                    vec2 p = texelFetch(iChannel0, ivec2(j, IPOS), 0).xy;
                    vec2 v = texelFetch(iChannel0, ivec2(j, IVEL), 0).xy;
                    float d = distance(pos, p);
                    float D = dot(vel - v, pos - p);
                    if (D < 0.0 && d < 2.0 * RADP) {
                        vec2 n = normalize(pos - p);
                        p += n * (RADP + RADP - d);
                        // https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects
                        vel -= (2.0 * M / (M + M)) * (D / length(pos - p)) * (pos - p);
                        // https://en.wikipedia.org/wiki/Specular_reflection#Vector_formulation
                        vel -= 2.0 * dot(vel, n) * n;
                        cll = true;
                        break;
                    }
                }
            }

            pos += vel * iTimeDelta;

            /****/ if (iv.y == IPOS) {
                fcol = vec4(pos, 0, 0);
            } else if (iv.y == IVEL) {
                fcol = vec4(vel, 0, 0);
            } else if (iv.y == ICOL) {
                fcol = vec4(int(cll));
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
        vec4 pos = texelFetch(iChannel0, ivec2(j, IPOS), 0);
        if (distance(uv, pos.xy) < RADP) {
            vec4 cll = texelFetch(iChannel0, ivec2(j, ICOL), 0);
            col = cll.x == 1.0 ? vec3(1, 0, 0) : vec3(0, 1, 0);
        }
    }

    fragColor = vec4(col, 1);
}
