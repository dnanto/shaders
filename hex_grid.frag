#define width 0.005

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

bool inhex(vec2 p, vec2 c, float R)
{
    float r = cos(radians(30.0)) * R;
    vec2 v1 = c + vec2(+0.0 * r, +1.0 * R);
    vec2 v2 = c + vec2(+1.0 * r, +0.5 * R);
    vec2 v3 = c + vec2(+1.0 * r, -0.5 * R);
    vec2 v4 = c + vec2(-0.0 * r, -1.0 * R);
    vec2 v5 = c + vec2(-1.0 * r, -0.5 * R);
    vec2 v6 = c + vec2(-1.0 * r, +0.5 * R);
    return (
        intri(p, c, v1, v2) ||
        intri(p, c, v2, v3) ||
        intri(p, c, v3, v4) ||
        intri(p, c, v4, v5) ||
        intri(p, c, v5, v6) ||
        intri(p, c, v6, v1)
    );
}

float random (vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float h = 3.0;
    float k = 3.0;

    vec2 p = fragCoord / iResolution.y;

    float R = 0.25;
    float r = cos(radians(30.0)) * R;

    vec3 col = vec3(0);
    vec2 c = round(p / vec2(2.0 * r, 3.0 * R)) * vec2(2.0 * r, 3.0 * R);
    if (inhex(p, c, R))
        col = 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4));

    fragColor = vec4(col, 1.0);
}
