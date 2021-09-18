float cross2(vec2 p, vec2 q)
{
    return p.x * q.y - p.y * q.x;
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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord / iResolution.y;

    float s = 0.25;
    float R = s * sqrt(3.0) / 3.0;
    float r = s * sqrt(3.0) / 6.0;
    float a = 0.5 * s * sqrt(3.0);

    vec2 hvec = vec2(s, 0);
    vec2 kvec = vec2(s/2., a);
    mat2 b = mat2(hvec, kvec);
    vec2 tri = b * round(inverse(b) * uv);

    vec3 col = vec3(1);
    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));

    // not 100% sure why this works, but it's based on the hex grid solution...
    bool inhex = inreg(uv, tri, 3.0, R, radians(90.0));
    if (!inhex)
        if (cross2(vec2(1.5 * s, a), tri - uv) < 0.)
            tri += (uv.x > tri.x) ? tri : -hvec;
        else
            tri += (uv.x > tri.x) ? tri : -kvec;

    if (inhex || inreg(uv, tri, 3.0, R, radians(90.0))) col = vec3(rnd);

    fragColor = vec4(col, 1.0);
}
