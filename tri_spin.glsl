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


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.y;

    vec4 p1 = vec4(0.25, 0.25, 0.0, 1); //vec4(0, b, -a, 1);
    vec4 p2 = vec4(0.75, 0.25, 0.0, 1); //vec4(b, a, 0, 1);
    vec4 p3 = vec4(0.50, 0.75, 0.0, 1); //vec4(-b, a, 0, 1);

    vec3 c = (p1.xyz + p2.xyz + p3.xyz) / 3.0;

    mat3 K = mat3(1);
    vec3 C = vec3(c.x, c.y, 0);

    float tht = radians(mod(iTime, 360.0) * 10.0);
    float psi = radians(mod(iTime, 360.0) * 15.0);
    float phi = radians(mod(iTime, 360.0) * 20.0);

    float sintht = sin(tht), sinpsi = sin(psi), sinphi = sin(phi);
    float costht = cos(tht), cospsi = cos(psi), cosphi = cos(phi);

    mat3 R = mat3(
        costht * cospsi,
        sintht * cospsi,
        -sinpsi,
        costht * sinpsi * sinphi - sintht * cosphi,
        sintht * sinpsi * sinphi + costht * cosphi,
        cospsi * sinphi,
        costht * sinpsi * cosphi + sintht * sinphi,
        sintht * sinpsi * cosphi - costht * sinphi,
        cospsi * cosphi
    );

    mat4x3 IC = mat4x3(mat3(1)); IC[3] = -C;
    mat4x3 P = (K * R) * IC;

    float cr = 0.25;
    float a = 0.5 * cr, b = 1.0 / (2.0 * phi) * cr;

    vec3 q1 = P * p1 + c;
    vec3 q2 = P * p2 + c;
    vec3 q3 = P * p3 + c;

    vec3 col = (
      intri(uv, q1.xy, q2.xy, q3.xy) ?
        0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4)) :
        vec3(0.0)
    );

    // Output to screen
    fragColor = vec4(col,1.0);
}
