#define cos30 cos(radians(30.0))
#define sqrt3 sqrt(3.0)

#define MODE_HEX              0
#define MODE_TRIHEX           1
#define MODE_SNUBHEX          2
#define MODE_RHOMBITRIHEX     3
#define MODE_DUALHEX          4
#define MODE_DUALTRIHEX       5
#define MODE_DUALSNUBHEX      6
#define MODE_DUALRHOMBITRIHEX 7

#define WIDTH 0.025

#define COLOR_BACKGROUND vec3(1.00)
#define COLOR_HEXAGON    vec3(0.50)
#define COLOR_VERTEX     vec3(0.25)
#define COLOR_TRIANGLE   vec3(0.75)
#define COLOR_LINE       vec3(0.00)

#define h 5.0
#define k 2.0
#define m MODE_DUALTRIHEX

struct Params {
    float R;     // circumradius
    float r;     // inradius
    float theta; // rotation
    vec2 hvec;   // basis vector
    vec2 kvec;   // basis vector
};

Params mode_to_params(int mode) {
    float R, r, theta;
    vec2 hvec, kvec;
    switch (m) {
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

bool in_tri(vec2 uv, vec2 v1, vec2 v2, vec2 v3)
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

bool in_reg(vec2 uv, vec2 c, float n, float R, float theta)
{
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
    // break-up hexagon-inscribed floret into 3 triangles
    float x = (3.0 * sqrt(3.0) * R) / 10.0;
    float X = x / cos(radians(30.0));
    float rtri = X * sqrt(3.0) / 6.0;
    float Rtri = X * sqrt(3.0) / 3.0;
    vec2 alpha = c + vec2(0, x + rtri);
    vec2 beta = c + vec2(X / 2.0, x + Rtri);
    vec2 gamma = c + vec2(X, x + rtri);
    vec2 delta = c + vec2(X, Rtri);
    for (float i = 0.0; i < 6.0; i++) {
        vec2 a = (alpha - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 b = (beta - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 g = (gamma - c) * rotmat2(radians(i * 60.0)) + c;
        vec2 d = (delta - c) * rotmat2(radians(i * 60.0)) + c;
        if (in_tri(uv, c, a, b) || in_tri(uv, c, b, g) || in_tri(uv, c, g, d))
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
    Params p = mode_to_params(m);
    vec2 t0 = vec2(0);
    vec2 t1 = mat2(p.hvec, p.kvec) * vec2(h, k);
    vec2 t2 = rotmat2(radians(60.0)) * t1;
    uv.x += t2.x < 0.0 ? t2.x : 0.0;

    float dw = p.R * WIDTH;
    if (m == MODE_HEX || m == MODE_DUALHEX || m == MODE_DUALRHOMBITRIHEX)
        p.R -= dw;

    mat2 b = mat2(p.hvec, p.kvec);
    vec2 hex = b * round(inverse(b) * uv);
    bool in_hex = in_reg(uv, hex, 6.0, p.R, p.theta);
    if (!in_hex)
        if (cross2(vec2(p.r, 0.5 * p.R), hex - uv) < 0.)
            hex += (uv.x > hex.x) ? p.kvec : -p.hvec;
        else
            hex += (uv.x > hex.x) ? p.hvec : -p.kvec;

    vec3 col = COLOR_BACKGROUND;

    if (in_hex || in_reg(uv, hex, 6.0, p.R, p.theta)) col = COLOR_HEXAGON;
    if (in_reg(uv, t0, 6.0, p.R, p.theta) ||
        in_reg(uv, t1, 6.0, p.R, p.theta) ||
        in_reg(uv, t2, 6.0, p.R, p.theta)
    ) col = COLOR_VERTEX;

    float R3 = p.R * sqrt3 / 3.0;
    float r3 = p.R * sqrt3 / 6.0;
    float a = R3 + r3;
    switch (m) {
        case MODE_SNUBHEX:
        {
            vec2 uv = uv;
            uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * p.R;
            vec2 c = vec2(p.R * round(uv.x / p.R), a * floor(uv.y / a));
            if (distline(uv, c, radians(+60.0)) < dw ||
                distline(uv, c, radians(-60.0)) < dw ||
                abs(uv.y - a * round(uv.y / a)) < dw
            ) col = COLOR_LINE;
            break;
        }
        case MODE_RHOMBITRIHEX:
        {
            float R = p.R;
            float r = p.r;
            float dx = R + r + r;
            float dy = R + a + R + a + R;
            vec2 c = vec2(dx * round(uv.x / dx), dy * round(uv.y / dy));
            if (in_reg(uv, c + vec2(0, +(R + R3)), 3.0, R3, radians(-90.0))                    ||
                in_reg(uv, c + vec2(0, -(R + R3)), 3.0, R3, radians(+90.0))                    ||
                in_reg(uv, c + vec2(+(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, radians(+90.0)) ||
                in_reg(uv, c + vec2(-(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, radians(+90.0)) ||
                in_reg(uv, c + vec2(+(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, radians(-90.0)) ||
                in_reg(uv, c + vec2(-(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, radians(-90.0))
            ) col = COLOR_TRIANGLE;
            break;
        }
        case MODE_DUALTRIHEX:
        {
            if (in_reg(uv, hex, 3.0, p.R, p.theta)                  ||
                in_reg(uv, hex, 3.0, p.R, p.theta + radians(180.0))
            )
                col = in_hex ? col : COLOR_TRIANGLE;
            else
                col = COLOR_BACKGROUND;

            if (distline(uv, hex, radians(+60.0)) < dw ||
                distline(uv, hex, radians(-60.0)) < dw ||
                abs(uv.y - hex.y) < dw
            ) col = COLOR_LINE;

            vec2 hex = b * round(inverse(b) * uv);
            if (cross2(vec2(p.r, 0.5 * p.R), hex - uv) < 0.)
                hex += (uv.x > hex.x) ? p.kvec : -p.hvec;
            else
                hex += (uv.x > hex.x) ? p.hvec : -p.kvec;
            if ( in_reg(uv, hex, 6.0, p.R / cos30 + dw, radians(30.0)) &&
                !in_reg(uv, hex, 6.0, p.R / cos30 - dw, radians(30.0))
            ) col = COLOR_LINE;

            break;
        }
        case MODE_DUALSNUBHEX:
        {
            if (in_floret(uv, t0, p.R + R3) ||
                in_floret(uv, t1, p.R + R3) ||
                in_floret(uv, t2, p.R + R3)
            ) {
                col = COLOR_VERTEX;
            }
            else {
                bool in_hex = false;
                mat2 b = mat2(p.hvec * 2.0, p.kvec * 2.0);
                {
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv - p.hvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv + p.kvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv + p.hvec + p.kvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (in_hex) col = COLOR_HEXAGON;
            }
            break;
        }
        case MODE_DUALRHOMBITRIHEX:
        {
            if (distline(uv, hex, radians(+60.0)) <= dw ||
                distline(uv, hex, radians(-60.0)) <= dw ||
                abs(uv.y - hex.y) < dw
            ) col = COLOR_LINE;
            break;
        }
    }

    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    if (in_tri(uv, vec2(0), t1, t2)) col = mix(rnd, col, 0.75);

    fragColor = vec4(col, 1.0);
}
