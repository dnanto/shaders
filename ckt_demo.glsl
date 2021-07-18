#define width 0.025
#define h 1.0
#define k 1.0

float plot(vec2 st, float pct)
{
  // The step() interpolation receives two parameters.
  // The first one is the limit or threshold, while
  // the second one is the value we want to check or pass.
  // Any value under the limit will return 0.0 while
  // everything above the limit will return 1.0.
  // 0 0 < < 0 - 0 =  0
  // 0 1 < > 0 - 1 = -1
  // 1 0 > < 1 - 0 =  1
  // 1 1 > > 1 - 1 =  0
  return step(pct - width, st.y) - step(pct + width, st.y);
}

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

bool inreg(vec2 p, vec2 c, float n, float R, float theta)
{
    float dt = radians(360.0 / n);
    for (float i = 0.0, j = 1.0; i < 6.0; i++, j++)
    {
        vec2 a = vec2(R * cos(dt * i + theta) + c.x, R * sin(dt * i + theta) + c.y);
        vec2 b = vec2(R * cos(dt * j + theta) + c.x, R * sin(dt * j + theta) + c.y);
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.y;

    float R = 0.075;
    float r = cos(radians(30.0)) * R;

    vec3 col = vec3(1);
    vec2 c = mat2(2. * r, 0., 0., 3.0 * R) * round(p / vec2(2.0 * r, 3.0 * R));
    if (inreg(p, c, 6.0, R, radians(30.0)))
        col = vec3(0.5);

    vec2 hvec = vec2(2.0 * r, 0.0 * R);
    vec2 kvec = vec2(1.0 * r, 1.5 * R);

    vec2 t1 = h * hvec + k * kvec;
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    if (intri(p, vec2(0), t1, t2))
        col = mix(col, 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4)), 0.5);

    fragColor = vec4(col, 1.0);
}
