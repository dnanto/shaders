// https://mathworld.wolfram.com/TriangleInterior.html
// http://www.sunshine2k.de/coding/java/PointInTriangle/PointInTriangle.html
// https://thebookofshaders.com/10/

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 P = fragCoord / iResolution.xy;

    // vec2 V1 = vec2(0.25, 0.00);
    // vec2 V2 = vec2(0.50, 1.00);
    // vec2 V3 = vec2(0.75, 0.00);

    vec2 V1 = vec2(random(vec2(iTime + 00.0, iTime + 01.0)), random(vec2(iTime + 03.0, iTime + 04.0)));
    vec2 V2 = vec2(random(vec2(iTime + 05.0, iTime + 06.0)), random(vec2(iTime + 07.0, iTime + 08.0)));
    vec2 V3 = vec2(random(vec2(iTime + 09.0, iTime + 10.0)), random(vec2(iTime + 11.0, iTime + 12.0)));

    vec2 w1 = V2 - V1;
    vec2 w2 = V3 - V1;
    float d = determinant(mat2(w1, w2));
    // check for d ≈ 0.0 ?
    float s = determinant(mat2(P - V1, w2)) / d;
    float t = determinant(mat2(w1, P - V2)) / d;

    vec3 col = (
        (s >= 0.0 && t >= 0.0 && (s + t) <= 1.0) ?
            0.5 + 0.5 * cos(iTime + P.xyx + vec3(0, 2, 4)) :
            vec3(0.0)
    );

    fragColor = vec4(col, 1.0);
}
