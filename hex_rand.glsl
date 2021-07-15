// https://mathworld.wolfram.com/TriangleInterior.html
// http://www.sunshine2k.de/coding/java/pointInTriangle/pointInTriangle.html
// https://thebookofshaders.com/10/

bool intri(vec2 p, vec2 v1, vec2 v2, vec2 v3)
{
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
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.xy;

    vec2 c = vec2(random(vec2(iTime + 01.0, iTime + 02.0)), random(vec2(iTime + 03.0, iTime + 04.0)));
    float R = random(vec2(iTime + 01.0));

    vec3 col = (
      inhex(p, c, R) ?
        0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4)) :
        vec3(0.0)
    );

    fragColor = vec4(col, 1.0);
}
