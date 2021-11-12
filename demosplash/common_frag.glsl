// math
#define phi (1.0 + sqrt(5.0)) / 2.0
#define rad30 radians(30.0)
#define rad60 radians(60.0)
#define rad90 radians(90.0)
#define cos30 cos(rad30)
#define sqrt3 sqrt(3.0)

// alias
#define T texture

// lattice pattern
#define MODE_HEX              0
#define MODE_TRIHEX           1
#define MODE_SNUBHEX          2
#define MODE_RHOMBITRIHEX     3
#define MODE_DUALHEX          4
#define MODE_DUALTRIHEX       5
#define MODE_DUALSNUBHEX      6
#define MODE_DUALRHOMBITRIHEX 7

// border width factor
#define WIDTH 0.05

// colors
#define COLOR_BACKGROUND vec3( 31, 120, 180) / 255.0
#define COLOR_FACE       vec3(178, 223, 138) / 255.0
#define COLOR_VERTEX     vec3( 51, 160,  44) / 255.0
#define COLOR_TRIANGLE   vec3(166, 206, 227) / 255.0
#define COLOR_LINE       vec3(166, 206, 227) / 255.0
#define COLOR_ON         vec3(117, 107, 177) / 255.0

// Caspar-Klug parameters
// #define h 16.0
// #define k 16.0
// #define m MODE_HEX

// polyhedra
//// constants
#define TET 0
#define OCT 1
#define ICO 2
//// tetrahedron
////// radius
#define TET_R 0.25
////// vertexes
#define TET_V vec4[] (               \
    vec4(+TET_R, +TET_R, +TET_R, 1), \
    vec4(-TET_R, +TET_R, -TET_R, 1), \
    vec4(+TET_R, -TET_R, -TET_R, 1), \
    vec4(-TET_R, +TET_R, -TET_R, 1), \
    vec4(-TET_R, -TET_R, +TET_R, 1), \
    vec4(+TET_R, -TET_R, -TET_R, 1)  \
)                                    \
////// faces
#define TET_F vec3[] ( \
    vec3(0, 1, 2),     \
    vec3(1, 4, 2),     \
    vec3(0, 2, 4),     \
    vec3(0, 4, 1)      \
)                      \
//// octahedron
////// radius
#define OCT_RADIUS 0.85
#define OCT_A      1.0 / (2.0 * sqrt(2.0)) * OCT_RADIUS
#define OCT_B      0.5 * OCT_RADIUS
////// vertexes
#define OCT_V vec4[] (          \
    vec4(-OCT_A, 0, +OCT_A, 1), \
    vec4(-OCT_A, 0, -OCT_A, 1), \
    vec4(0, +OCT_B, 0, 1),      \
    vec4(+OCT_A, 0, -OCT_A, 1), \
    vec4(+OCT_A, 0, +OCT_A, 1), \
    vec4(0, -OCT_B, 0, 1)       \
)                               \
////// faces
#define OCT_F vec3[] ( \
    vec3(0, 1, 2),     \
    vec3(1, 3, 2),     \
    vec3(3, 4, 2),     \
    vec3(4, 0, 2),     \
    vec3(3, 1, 5),     \
    vec3(1, 0, 5),     \
    vec3(4, 3, 5),     \
    vec3(0, 4, 5)      \
)                      \
//// icosahedron
////// radius
#define ICO_RADIUS 0.85
#define ICO_A      0.5 * ICO_RADIUS
#define ICO_B      1.0 / (2.0 * phi) * ICO_RADIUS
////// vertexes
#define ICO_V vec4[] (        \
  vec4(0, +ICO_B, -ICO_A, 1), \
  vec4(+ICO_B, +ICO_A, 0, 1), \
  vec4(-ICO_B, +ICO_A, 0, 1), \
  vec4(0, +ICO_B, +ICO_A, 1), \
  vec4(0, -ICO_B, +ICO_A, 1), \
  vec4(-ICO_A, 0, +ICO_B, 1), \
  vec4(0, -ICO_B, -ICO_A, 1), \
  vec4(+ICO_A, 0, -ICO_B, 1), \
  vec4(+ICO_A, 0, +ICO_B, 1), \
  vec4(-ICO_A, 0, -ICO_B, 1), \
  vec4(+ICO_B, -ICO_A, 0, 1), \
  vec4(-ICO_B, -ICO_A, 0, 1)  \
)                             \
////// faces
#define ICO_F vec3[] (  \
  vec3( 0,  1,  2),     \
  vec3( 3,  2,  1),     \
  vec3( 3,  4,  5),     \
  vec3( 3,  8,  4),     \
  vec3( 0,  6,  7),     \
  vec3( 0,  9,  6),     \
  vec3( 4, 10, 11),     \
  vec3( 6, 11, 10),     \
  vec3( 2,  5,  9),     \
  vec3(11,  9,  5),     \
  vec3( 1,  7,  8),     \
  vec3(10,  8,  7),     \
  vec3( 3,  5,  2),     \
  vec3( 3,  1,  8),     \
  vec3( 0,  2,  9),     \
  vec3( 0,  7,  1),     \
  vec3( 6,  9, 11),     \
  vec3( 6, 10,  7),     \
  vec3( 4, 11,  5),     \
  vec3( 4,  8, 10)      \
)                       \

// image
#define img_m 22
#define img_n 15
#define img int[] (                                \
    0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0,   \
      0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, \
    0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0,   \
      0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, \
    0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,   \
      0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, \
    0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0,   \
      0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, \
    0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,   \
      0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, \
    0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0,   \
      1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, \
    0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0,   \
      0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, \
    0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,   \
      0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
    0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,   \
      1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, \
    0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,   \
      0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, \
    0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,   \
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  \
)                                                  \

// message
#define hex_codes float[] (                                                                   \
    16127.0, 12735.0,  9087.0, 10681.0, 16313.0, 11263.0, 19199.0, 14719.0, 16063.0, 14527.0, \
    12289.0, 16145.0, 14015.0,  8511.0, 15549.0, 14521.0, 14777.0,  3839.0, 16071.0, 18617.0, \
    13287.0, 10687.0, 14649.0, 16191.0, 14617.0, 23709.0, 14007.0, 16263.0, 10227.0, 16255.0, \
    15873.0, 12283.0, 16363.0, 16015.0, 15343.0, 15359.0, 15939.0, 16383.0, 16079.0,  8481.0, \
    18569.0, 16425.0, 11777.0, 20219.0,  8193.0, 16391.0, 17927.0, 16767.0, 16193.0           \
)                                                                                             \

#define message float[] (                                                                              \
        0.0,     0.0,      0.0,    0.0,     0.0,                                                       \
    16313.0, 11263.0, 15549.0, 14777.0, 13287.0,  3839.0,  8511.0, 16127.0, 13287.0, 16063.0,     0.0, \
    12283.0, 16255.0, 12283.0, 15873.0,     0.0,                                                       \
    12289.0, 13287.0,      0.0,                                                                        \
    14777.0, 14521.0,  8511.0, 14336.0, 14521.0, 11263.0,                                              \
     8192.0,  8192.0,  8192.0                                                                          \
)                                                                                                      \

// scene frame thresholds
#define checkpoints int[] (                                                 \
    60 * (2),                              /* intro */                     \
    60 * (2 + 6),                         /* plane lattice cycle */       \
    60 * (2 + 6 + 6),                    /* icosahedral lattice cycle */ \
    60 * (2 + 6 + 6 + 6),               /* deer */                      \
    60 * (2 + 6 + 6 + 6 + 6),          /* random initialization */     \
    60 * (2 + 6 + 6 + 6 + 6 + 6),     /* cellular automata */         \
    60 * (2 + 6 + 6 + 6 + 6 + 6 + 6) /* outro */                     \
)                                                                           \


int frame_to_mode(int frame) {
    if (frame < checkpoints[0]) {
    } else if (frame < checkpoints[1]) {
        return int(mod(round(float(frame - checkpoints[1]) / 120.0), 8.0));
    } else if (frame < checkpoints[2]) {
        return int(mod(round(float(frame - checkpoints[2]) / 120.0), 8.0));
    } else if (frame < checkpoints[3]) {
        return 0;
    }
    return 0;
}

int frame_to_h(int frame) {
    if (frame < checkpoints[0]) {
    } else if (frame < checkpoints[1]) {
        float n = 30.0;
        return int(1.0 + round(n / 2.0 * sin(float(frame - checkpoints[1]) / n)) + floor(n / 2.0));
    } else if (frame < checkpoints[2]) {
        float n = 8.0;
        return int(1.0 + round(n / 2.0 * sin(float(frame - checkpoints[2]) / n)) + floor(n / 2.0));
    } else if (frame < checkpoints[3]) {
        return 16;
    } else if (frame < checkpoints[4]) {
        return 16;
    } else if (frame < checkpoints[5]) {
        return 16;
    }
    return 1;
}

int frame_to_k(int frame) {
    if (frame < checkpoints[0]) {
    } else if (frame < checkpoints[1]) {
        return 0;
    } else if (frame < checkpoints[2]) {
        float n = 8.0;
        return int(round(n / 2.0 * sin(float(frame - checkpoints[2]) / 10.0)) + floor(n / 2.0));
    } else if (frame < checkpoints[3]) {
        return 16;
    } else if (frame < checkpoints[4]) {
        return 16;
    } else if (frame < checkpoints[5]) {
        return 16;
    }
    return 0;
}

int frame_to_polyhedra(int frame) {
    if (frame < checkpoints[0]) {
        return ICO;
    } else if (frame < checkpoints[1]) {
        return ICO;
    } else if (frame < checkpoints[2]) {
        return int(mod(round(float(frame - checkpoints[2]) / 240.0), 3.0));
    } else if (frame < checkpoints[3]) {
        return int(mod(round(float(frame - checkpoints[2]) / 240.0), 3.0));
    } else if (frame < checkpoints[4]) {
        return int(mod(round(float(frame - checkpoints[2]) / 240.0), 3.0));
    } else if (frame < checkpoints[5]) {
        return ICO;
    }
}

// lattice parameters
struct Params {
    float R;     // circumradius
    float r;     // inradius
    float theta; // rotation
    vec2 hvec;   // basis vector
    vec2 kvec;   // basis vector
};

Params mode_to_params(int mode, float h, float k) {
    float R, r, theta;
    vec2 hvec, kvec;
    switch (mode) {
        case MODE_DUALHEX:
        case MODE_DUALRHOMBITRIHEX:
        case MODE_HEX:
        {
            R = 1.0 / ((h + k) * 1.5);
            r = cos30 * R;
            theta = 30.0;
            hvec = vec2(2.0 * r, 0.0);
            kvec = vec2(r, 1.5 * R);
            break;
        }
        case MODE_DUALTRIHEX:
        case MODE_TRIHEX:
        {
            R = 1.0 / ((h + k) * 2.0 * cos30);
            r = cos30 * R;
            theta = 0.0;
            hvec = vec2(2.0 * R, 0.0);
            kvec = vec2(R, 2.0 * r);
            break;
        }
        case MODE_DUALSNUBHEX:
        case MODE_SNUBHEX:
        {
            R = 1.0 / (h < k / 2.0 ? k * 3.0 * cos30 + h * cos30 : h * 3.0 * cos30 + 2.0 * k * cos30);
            r = cos30 * R;
            theta = 0.0;
            hvec = vec2(2.5 * R, r);
            kvec = vec2(0.5 * R, 3.0 * r);
            break;
        }
        case MODE_RHOMBITRIHEX:
        {
            R = 1.0 / ((h + k) * (1.5 + sqrt3 / 2.0));
            r = cos30 * R;
            theta = 30.0;
            hvec = vec2(R + 2.0 * r, 0.0);
            kvec = vec2(r + 0.5 * R, (1.5 + sqrt3 / 2.0) * R);
            break;
        }
    }
    return Params(R, r, radians(theta), hvec, kvec);
}

float cross2(vec2 p, vec2 q) {
    return p.x * q.y - p.y * q.x;
}

mat2 rotmat2(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(c, s, -s, c);
}

mat3 rotmat3(vec3 angle) {
    float sintht = sin(angle.x), sinpsi = sin(angle.y), sinphi = sin(angle.z);
    float costht = cos(angle.x), cospsi = cos(angle.y), cosphi = cos(angle.z);
    return mat3(
        costht * cospsi,
        sintht * cospsi,
        -sinpsi,
        costht * sinpsi * sinphi - sintht * cosphi,
        sintht * sinpsi * sinphi + costht * cosphi,
        cospsi * sinphi,
        costht * sinpsi * cosphi + sintht * sinphi,
        sintht * sinpsi * cosphi - costht * sinphi,
        cospsi * cosphi
    );
}

bool in_tri(vec2 uv, vec2 v1, vec2 v2, vec2 v3) {
    // https://mathworld.wolfram.com/TriangleInterior.html
    // http://www.sunshine2k.de/coding/java/pointInTriangle/pointInTriangle.html
    vec2 w1 = v2 - v1;
    vec2 w2 = v3 - v1;
    float d = determinant(mat2(w1, w2));
    // check for d ≈ 0.0 ?
    float s = determinant(mat2(uv - v1, w2)) / d;
    float t = determinant(mat2(w1, uv - v2)) / d;
    return s >= 0.0 && t >= 0.0 && (s + t) <= 1.0;
}

bool in_reg(vec2 uv, vec2 c, float n, float R, float theta) {
    // break-up regular polygon into triangles
    float dt = radians(360.0 / n);
    for (float i = 0.0, j = 1.0; i < n; i++, j++)
    {
        vec2 a = R * vec2(cos(dt * i + theta), sin(dt * i + theta)) + c;
        vec2 b = R * vec2(cos(dt * j + theta), sin(dt * j + theta)) + c;
        if (in_tri(uv, a, b, c))
            return true;
    }
    return false;
}

bool in_floret(vec2 uv, vec2 c, float R) {
    // progressively break-up hexagon-inscribed floret into 3 triangles
    float x = (3.0 * sqrt(3.0) * R) / 10.0;
    float X = x / cos30;
    float rtri = X * sqrt(3.0) / 6.0;
    float Rtri = X * sqrt(3.0) / 3.0;
    vec2 alpha = c + vec2(0, x + rtri);
    vec2 beta = c + vec2(X / 2.0, x + Rtri);
    vec2 gamma = c + vec2(X, x + rtri);
    vec2 delta = c + vec2(X, Rtri);
    for (float i = 0.0; i < 6.0; i++) {
        vec2 a = (alpha - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 b = (beta  - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 g = (gamma - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 d = (delta - c) * rotmat2(radians(i * 60.0)) + c;
        if (in_tri(uv, c, a, b) || in_tri(uv, c, b, g) || in_tri(uv, c, g, d))
            return true;
    }
    return false;
}

vec2 uv_to_hex(vec2 uv, Params p) {
    // get central hex coordinate
    mat2 b = mat2(p.hvec, p.kvec);
    vec2 hex = b * round(inverse(b) * uv);
    bool inhex = in_reg(uv, hex, 6.0, p.R, p.theta);
    // adjust hex coordinate due to overlap
    if (!inhex)
        if (cross2(vec2(p.r, 0.5 * p.R), hex - uv) < 0.)
            hex += (uv.x > hex.x) ? p.kvec : -p.hvec;
        else
            hex += (uv.x > hex.x) ? p.hvec : -p.kvec;
    return hex;
}

float distline(vec2 uv, vec2 p, float theta) {
    // https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    return abs(cos(theta) * (p.y - uv.y) - sin(theta) * (p.x - uv.x));
}

float random(vec2 seed) {
    // https://thebookofshaders.com/10/
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 hex_display(vec2 uv, vec2 pos, float chr, float R, float B, vec3 col) {
    // uv  the uv
    // pos the centreal display position
    // chr the character code to display
    // R   the hexagon circumradius
    // B   the border width
    // col the default color
    //
    //     0    5    8  -
    //    1         9    |
    //   2    6    A      > display bit mapping
    //  3         B      |
    // 4    7    C      -
    //
    // A a 16127          n 14521        0 16255  _ 08481
    // b   12735          o 14777        1 15873  - 18569
    // C c 09087 10681  P   03839        2 12283  : 16425
    //   d 16313          q 16071        3 16363  ! 11777
    // E   11263          r 18617        4 16015  ? 20219
    // F   19199        S   13287        5 15343  . 08193
    // G g 14719          t 10687        6 15359  ' 16391
    // H h 16063 14527  U u 16191 14649  7 15939  " 17927
    //   i 12289        V   14617        8 16383  [ 16767
    // J   16145          w 23709        9 16079  ] 16193
    // K   14015        X   14007
    // L   08511          y 16263
    // M   15549        Z   10227

    float r = R * cos30;
    float theta = radians(30.0);
    float n = chr;
    // set display according to bit index
    for (int i = 0; i < 13; i++) {
        float q = floor(n / 2.0);
        if (mod(q, 2.0) == 1.0) {
            float ir = 0.0;
            float ic = 0.0;
            /**/ if (i == 0 || i == 5 || i == 8 ) ir = +2.0;
            else if (i == 1 || i == 9           ) ir = +1.0;
            else if (i == 3 || i == 11          ) ir = -1.0;
            else if (i == 4 || i == 7 || i == 12) ir = -2.0;
            /**/ if (i <= 4                     ) ic = -1.0;
            else if (i >= 8                     ) ic = +1.0;
            float dx = ic * 2.0 * r + ir * r;
            float dy = ir * 1.5 * R;
            if (in_reg(uv, pos + vec2(dx, dy), 6.0, R - B, theta)) {
                col = vec3(0.75);
                break;
            }
        }
        n = q;
    }
    return col;
}
