#define h 4.0
#define k 8.0

mat2 rotmat2(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat2(c, s, -s, c);
}

bool intri(vec2 p, vec2 v1, vec2 v2, vec2 v3)
{
    // https://mathworld.wolfram.com/TriangleInterior.html
    // http://www.sunshine2k.de/coding/java/pointInTriangle/pointInTriangle.html
    vec2 w1 = v2 - v1;
    vec2 w2 = v3 - v1;
    float d = determinant(mat2(w1, w2));
    // check for d ≈ 0.0 ?
    float s = determinant(mat2(p - v1, w2)) / d;
    float t = determinant(mat2(w1, p - v2)) / d;
    return s >= 0.0 && t >= 0.0 && (s + t) <= 1.0;
}

bool inreg(vec2 p, vec2 c, int n, float R, float theta)
{
    float dt = radians(360.0 / float(n));
    for (float i = 0.0, j = 1.0; i < 6.0; i++, j++)
    {
        vec2 a = R * vec2(cos(dt * i + theta), sin(dt * i + theta)) + c;
        vec2 b = R * vec2(cos(dt * j + theta), sin(dt * j + theta)) + c;
        if (intri(p, a, b, c))
            return true;
    }
    return false;
}

float random (vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = fragCoord / iResolution.y;

    float R = 1. / ((h + k) * 1.5);
    float r = cos(radians(30.0)) * R;

    p.x += h < k ? r * (h - k) : 0.0;

    vec2 hvec = vec2(2.0 * r, 0.0 * R);
    vec2 kvec = vec2(1.0 * r, 1.5 * R);

    vec2 t0 = vec2(0);
    vec2 t1 = h * hvec + k * kvec;
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    vec3 rnd = 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4));

    mat2 b = mat2(2.0 * r, 0.0, 0.0, 3.0 * R);
    vec2 s = vec2(2.0 * r, 3.0 * R);
    vec2 c = b * round(p / s);
    vec2 d = b * floor(p / s) + s / 2.0;

    R -= R * 0.05;

    vec3 col = intri(p, vec2(0), t1, t2) ? rnd : vec3(0.95);

    if (inreg(p, c, 6, R, radians(30.0)) || inreg(p, d, 6, R, radians(30.0)))
        col = vec3(0.5);

    if (inreg(p, t0, 6, R, radians(30.0)) || inreg(p, t1, 6, R, radians(30.0)) || inreg(p, t2, 6, R, radians(30.0)))
        col = vec3(0.25);

    fragColor = vec4(col, 1.0);
}
