#define h 9.0
#define k 6.0

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

float random (vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord / iResolution.y;

    // float R = 1.0 / ((h + k) * 1.5);
    // float R = 1.0 / ((h + k) * 2.0);
    // float R = 1.0 / ((h + k) * 3.0 * cos(radians(30.0)) - k * cos(radians(30.0)));
    float R = 1.0 / ((h + k) * 3.0 * cos(radians(30.0)) - k * cos(radians(30.0)));
    float r = cos(radians(30.0)) * R;

    // vec2 hvec = vec2(2.0 * r, 0.0    );
    // vec2 kvec = vec2(      r, 1.5 * R);
    // vec2 hvec = vec2(2.0 * R, 0.0    );
    // vec2 kvec = vec2(      R, 2.0 * r);
    // vec2 hvec = vec2(2.5 * R,       r);
    // vec2 kvec = vec2(0.5 * R, 3.0 * r);
    vec2 hvec = vec2(R + 2.0 * r, 0.0);
    vec2 kvec = vec2(r + 0.5 * R, 1.5 * R + R * sqrt(3.0) / 2.0);

    vec2 t0 = vec2(0);
    vec2 t1 = mat2(hvec, kvec) * vec2(h, k);
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    // uv.x += h < k ? r * (h - k) : 0.0;
    // uv.x += h < k ? R * (h - k) : 0.0;
    // uv.x += t2.x < 0.0 ? t2.x : 0.0; // h < k ? 1.5 * R * (h - k) : 0.0;
    uv.x += t2.x < 0.0 ? t2.x : 0.0; // h < k ? 1.5 * R * (h - k) : 0.0;

    // mat2 b = mat2(2.0 * r, 0.0, 0.0, 3.0 * R);
    // mat2 b = mat2(2.0 * R, 0.0, 0.0, 4.0 * r);
    // mat2 b = mat2(hvec, kvec);
    mat2 b = mat2(hvec, kvec);
    vec2 hex1 = b * round(inverse(b) * uv);
    // vec2 hex2 = b * floor(inverse(b) * uv) + vec2(1.0 * r, 1.5 * R);
    // vec2 hex2 = b * floor(inverse(b) * uv) + vec2(1.0 * R, 2.0 * r);
    // vec2 hex2 = hex1;
    vec2 hex2 = hex1;

    vec3 rnd = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    vec3 col = intri(uv, vec2(0), t1, t2) ? rnd : vec3(0.90);

    // R -= R * 0.05;
    // R -= R * 0.00;
    // R -= R * 0.00;
    R -= R * 0.00;

    // float theta = 30.0;
    // float theta = 0.0;
    // float theta = 0.0;
    float theta = 30.0;

    if (
        inreg(uv, hex1, 6.0, R, radians(theta)) ||
        inreg(uv, hex2, 6.0, R, radians(theta))
    )
        col = vec3(0.5);

    if (
        inreg(uv, t0, 6.0, R, radians(theta)) ||
        inreg(uv, t1, 6.0, R, radians(theta)) ||
        inreg(uv, t2, 6.0, R, radians(theta))
    )
        col = vec3(0.25);

    fragColor = vec4(col, 1.0);
}
