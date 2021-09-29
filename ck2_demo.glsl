#define cos30 cos(radians(30.0))
#define sqrt3 sqrt(3.0)

#define MODE_HEX 1
#define MODE_TRIHEX 2
#define MODE_SNUBHEX 3
#define MODE_RHOMBITRIHEX 4
#define MODE_DUALHEX 5
#define MODE_DUALTRIHEX 6
#define MODE_DUALSNUBHEX 7
#define MODE_DUALRHOMBITRIHEX 8

#define h 4.0
#define k 1.0
#define m MODE_DUALRHOMBITRIHEX

#define TRI_LINE_WIDTH 0.000

float cross2(vec2 p, vec2 q)
{
    return p.x * q.y - p.y * q.x;
}

mat2 rotmat2(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat2(c, s, -s, c);
}

bool intri(vec2 uv, vec2 v1, vec2 v2, vec2 v3)
{
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

bool inreg(vec2 uv, vec2 c, float n, float R, float theta)
{
    float dt = radians(360.0 / n);
    for (float i = 0.0, j = 1.0; i < n; i++, j++)
    {
        vec2 a = R * vec2(cos(dt * i + theta), sin(dt * i + theta)) + c;
        vec2 b = R * vec2(cos(dt * j + theta), sin(dt * j + theta)) + c;
        if (intri(uv, a, b, c))
            return true;
    }
    return false;
}

float distline(vec2 uv, vec2 p, float theta) {
    // https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    return abs(cos(theta) * (p.y - uv.y) - sin(theta) * (p.x - uv.x));
}

float random (vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord / iResolution.y;

    float R;
    float r;
    float theta;
    vec2 hvec;
    vec2 kvec;
    switch (m) {
        case MODE_DUALHEX:
        case MODE_DUALRHOMBITRIHEX:
        case MODE_HEX:
            R = 1.0 / ((h + k) * 1.5);
            r = cos30 * R;
            hvec = vec2(2.0 * r, 0.0);
            kvec = vec2(r, 1.5 * R);
            theta = 30.0;
            break;
        case MODE_TRIHEX:
            R = 1.0 / ((h + k) * 2.0 * cos30);
            r = cos30 * R;
            hvec = vec2(2.0 * R, 0.0);
            kvec = vec2(R, 2.0 * r);
            theta = 0.0;
            break;
        case MODE_SNUBHEX:
            R = 1.0 / (h < k / 2.0 ? k * 3.0 * cos30 + h * cos30 : h * 3.0 * cos30 + 2.0 * k * cos30);
            r = cos30 * R;
            hvec = vec2(2.5 * R, r);
            kvec = vec2(0.5 * R, 3.0 * r);
            theta = 0.0;
            break;
        case MODE_RHOMBITRIHEX:
            R = 1.0 / ((h + k) * (1.5 + sqrt3 / 2.0));
            r = cos30 * R;
            hvec = vec2(R + 2.0 * r, 0.0);
            kvec = vec2(r + 0.5 * R, (1.5 + sqrt3 / 2.0) * R);
            theta = 30.0;
            break;
    }

    vec2 t0 = vec2(0);
    vec2 t1 = mat2(hvec, kvec) * vec2(h, k);
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    uv.x += t2.x < 0.0 ? t2.x : 0.0;

    mat2 b = mat2(hvec, kvec);
    vec2 hex = b * round(inverse(b) * uv);

    if (m == MODE_HEX || m == MODE_DUALHEX || m == MODE_DUALRHOMBITRIHEX)
        R -= R * 0.025;

    bool inhex = inreg(uv, hex, 6.0, R, radians(theta));
    if (!inhex)
        if (cross2(vec2(r, 0.5 * R), hex - uv) < 0.)
            hex += (uv.x > hex.x) ? kvec : -hvec;
        else
            hex += (uv.x > hex.x) ? hvec : -kvec;

    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    vec3 col = vec3(1);

    /*
        if (
            inreg(uv, hex, 3.0, R, radians(theta)) ||
            inreg(uv, hex, 3.0, R, radians(theta + 180.0))
        ) col = vec3(0.75);
     */

    if (inhex || inreg(uv, hex, 6.0, R, radians(theta))) col = vec3(0.5);
    if (
        inreg(uv, t0, 6.0, R, radians(theta)) ||
        inreg(uv, t1, 6.0, R, radians(theta)) ||
        inreg(uv, t2, 6.0, R, radians(theta))
    ) col = mix(col, vec3(0), 0.5);


    float R3 = R * sqrt3 / 3.0;
    float r3 = R * sqrt3 / 6.0;
    float a = R3 + r3;
    switch (m) {
        case MODE_SNUBHEX:
        {
            if (!inhex) {
                {   // triangles
                    vec2 uv = uv;

                    uv.x -= R / 2.0;
                    uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * R;

                    vec2 p = vec2(R * round(uv.x / R), a * floor(uv.y / a) + r3);
                    col = inreg(uv, p, 3.0, R3, radians(90.0)) ? col : vec3(0);
                }
                {   // lines
                    vec2 uv = uv;
                    uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * R;

                    float ci = round(uv.x / R);
                    float ri = floor(uv.y / a);

                    vec2 p = vec2(R * ci, a * ri);

                    if (distline(uv, p, radians(+60.0)) < TRI_LINE_WIDTH) col = vec3(0.25);
                    if (distline(uv, p, radians(-60.0)) < TRI_LINE_WIDTH) col = vec3(0.25);
                    if (abs(uv.y - a * round(uv.y / a)) < TRI_LINE_WIDTH) col = vec3(0.25);
                }
            }
            break;
        }
        case MODE_RHOMBITRIHEX:
        {   // triangles
            if (!inhex) {
                float dx = R + r + r;
                float dy = R + a + R + a + R;
                {
                    vec2 p = vec2(dx * round(uv.x / dx), dy * round(uv.y / dy));
                    float radius = r + R;
                    if (
                        inreg(uv, p + vec2(0, +(R + R3)), 3.0, R3, radians(-90.0))                    ||
                        inreg(uv, p + vec2(0, -(R + R3)), 3.0, R3, radians(+90.0))                    ||
                        inreg(uv, p + vec2(+(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, radians(+90.0)) ||
                        inreg(uv, p + vec2(-(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, radians(+90.0)) ||
                        inreg(uv, p + vec2(+(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, radians(-90.0)) ||
                        inreg(uv, p + vec2(-(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, radians(-90.0))
                     ) col = vec3(0.75);
                }
            }
            break;
        }
        case MODE_DUALRHOMBITRIHEX:
        {   // lines
            if (distline(uv, hex, radians(+60.0)) < 0.0025) col = vec3(1.0);
            if (distline(uv, hex, radians(-60.0)) < 0.0025) col = vec3(1.0);
            if (abs(uv.y - hex.y) < 0.0025) col = vec3(1.0);
            break;
        }
    }

    if (intri(uv, vec2(0), t1, t2)) col = mix(rnd, col, 0.75);

    fragColor = vec4(col, 1.0);
}
