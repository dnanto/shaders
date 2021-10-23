const float radius = 0.5;
const float phi = (1.0 + sqrt(5.0)) / 2.0;
const float a = 0.5 * radius, b = 1.0 / (2.0 * phi) * radius;
const vec4[] v = vec4[] (
    vec4(0, b, -a, 1),
    vec4(b, a, 0, 1),
    vec4(-b, a, 0, 1),
    vec4(0, b, a, 1),
    vec4(0, -b, a, 1),
    vec4(-a, 0, b, 1),
    vec4(0, -b, -a, 1),
    vec4(a, 0, -b, 1),
    vec4(a, 0, b, 1),
    vec4(-a, 0, -b, 1),
    vec4(b, -a, 0, 1),
    vec4(-b, -a, 0, 1)
);

const vec3[] f = vec3[] (
 vec3(0, 1, 2), vec3(3, 2, 1), vec3(3, 4, 5), vec3(3, 8, 4), vec3(0, 6, 7),
 vec3(0, 9, 6), vec3(4, 10, 11), vec3(6, 11, 10), vec3(2, 5, 9), vec3(11, 9, 5),
 vec3(1, 7, 8), vec3(10, 8, 7), vec3(3, 5, 2), vec3(3, 1, 8), vec3(0, 2, 9),
 vec3(0, 7, 1), vec3(6, 9, 11), vec3(6, 10, 7), vec3(4, 11, 5), vec3(4, 8, 10)
);

mat3 rotmat3(vec3 angle)
{
    float sintht = sin(angle.x), sinpsi = sin(angle.y), sinphi = sin(angle.z);
    float costht = cos(angle.x), cospsi = cos(angle.y), cosphi = cos(angle.z);
    return mat3(
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;

    vec3 t = vec3(
        radians(mod(iTime, 360.0) * 10.0),
        radians(mod(iTime, 360.0) * 15.0),
        radians(mod(iTime, 360.0) * 20.0)
    );

    mat3 K = mat3(1);             // calibration
    vec3 C = vec3(0.);            // translation
    mat3 R = rotmat3(t);          // rotation
    mat4x3 IC = mat4x3(mat3(1));
    IC[3] = -C;
    mat4x3 P = (K * R) * IC;      // projection

    vec3 col = vec3(1);
    for (int i = 0; i < 20; i++)
    {
        vec3 q1 = P * v[int(f[i].x)] + 0.5;
        vec3 q2 = P * v[int(f[i].y)] + 0.5;
        vec3 q3 = P * v[int(f[i].z)] + 0.5;
        col = mix(
            col,
            intri(uv, q1.xy, q2.xy, q3.xy) ?
                0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4)) :
                vec3(1.0),
            0.25
        );
    }

    fragColor = vec4(col, 1.0);
}
