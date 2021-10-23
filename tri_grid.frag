#define TRI_LINE_WIDTH 0.005

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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.y;

    float s = 0.25;
    float R = s * sqrt(3.0) / 3.0;
    float r = s * sqrt(3.0) / 6.0;
    float a = R + r;

    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));

    {
        vec2 uv = uv;

        uv.x -= s / 2.0;
        uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * s;

        float ci = round(uv.x / s);
        float ri = floor(uv.y / a);

        vec2 p = vec2(s * ci, a * ri + r);

        col = inreg(uv, p, 3.0, R, radians(90.0)) ? col : vec3(0);
    }

    {
        vec2 uv = uv;

        uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * s;

        float ci = round(uv.x / s);
        float ri = floor(uv.y / a);

        vec2 p = vec2(s * ci, a * ri);

        if (distline(uv, p, radians(60.0)) < TRI_LINE_WIDTH) col = vec3(0.5);
        if (distline(uv, p, radians(-60.0)) < TRI_LINE_WIDTH) col = vec3(0.5);
        if (abs(uv.y - a * round(uv.y / a)) < TRI_LINE_WIDTH) col = vec3(0.5);
    }

    fragColor = vec4(col, 1.0);
}
