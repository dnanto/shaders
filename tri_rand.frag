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

float random (vec2 st)
{
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.xy;

    vec2 v1 = vec2(random(vec2(iTime + 01.0, iTime + 02.0)), random(vec2(iTime + 03.0, iTime + 04.0)));
    vec2 v2 = vec2(random(vec2(iTime + 05.0, iTime + 06.0)), random(vec2(iTime + 07.0, iTime + 08.0)));
    vec2 v3 = vec2(random(vec2(iTime + 09.0, iTime + 10.0)), random(vec2(iTime + 11.0, iTime + 12.0)));

    vec3 col = (
      intri(p, v1, v2, v3) ?
        0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4)) :
        vec3(0.0)
    );

    fragColor = vec4(col, 1.0);
}
