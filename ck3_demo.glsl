// Common

#define width 0.025
#define h 6.0
#define k 2.0

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
  vec3(0, 1, 2), vec3(3, 2, 1),
  vec3(3, 4, 5), vec3(3, 8, 4),
  vec3(0, 6, 7), vec3(0, 9, 6),
  vec3(4, 10, 11), vec3(6, 11, 10),
  vec3(2, 5, 9), vec3(11, 9, 5),
  vec3(1, 7, 8), vec3(10, 8, 7),
  vec3(3, 5, 2), vec3(3, 1, 8),
  vec3(0, 2, 9), vec3(0, 7, 1),
  vec3(6, 9, 11), vec3(6, 10, 7),
  vec3(4, 11, 5), vec3(4, 8, 10)
);

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

mat2 rotmat2(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat2(c, s, -s, c);
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

// Buffer A

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.xy;

    float R = 0.075;
    float r = cos(radians(30.0)) * R;

    vec2 hvec = vec2(2.0 * r, 0.0 * R);
    vec2 kvec = vec2(1.0 * r, 1.5 * R);

    vec2 t1 = h * hvec + k * kvec;
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    vec3 rnd = 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4));
    vec3 col = vec3(rnd);

    vec2 c = mat2(2.0 * r, 0.0, 0.0, 3.0 * R) * round(p / vec2(2.0 * r, 3.0 * R));
    vec2 d = mat2(2.0 * r, 0.0, 0.0, 3.0 * R) * floor(p / vec2(2.0 * r, 3.0 * R)) + vec2(1.0 * r, 1.5 * R);

    R -= R * 0.05;

    if (inreg(p, c, 6.0, R, radians(30.0)) || inreg(p, d, 6.0, R, radians(30.0)))
        col = vec3(1.0);

    if (inreg(p, vec2(0), 6.0, R, radians(30.0)))
        col = vec3(0.25);

    if (inreg(p, t1, 6.0, R, radians(30.0)))
        col = vec3(0.25);

    if (inreg(p, t2, 6.0, R, radians(30.0)))
        col = vec3(0.25);

    if (intri(p, vec2(0), t1, t2))
        col = mix(col, rnd, 0.5);

    fragColor = vec4(col, 1.0);
}

// Image

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float R = 0.075;
    float r = cos(radians(30.0)) * R;
    vec2 hvec = vec2(2.0 * r, 0.0 * R);
    vec2 kvec = vec2(1.0 * r, 1.5 * R);
    vec2 t1 = h * hvec + k * kvec;
    vec2 t2 = rotmat2(radians(60.0)) * t1;

    mat3 X = mat3(
        0, 0, 1,
        t1.x, t1.y, 1,
        t2.x, t2.y, 1
    );

    vec2 uv = fragCoord / iResolution.xy;

    vec3 t = vec3(
        radians(mod(iTime, 360.0) * 10.0),
        radians(mod(iTime, 360.0) * 15.0),
        radians(mod(iTime, 360.0) * 20.0)
    );

    mat3 K = mat3(1);             // calibration
    vec3 C = vec3(0.);            // translation
    mat3 Q = rotmat3(t);          // rotation
    mat4x3 IC = mat4x3(mat3(1));
    IC[3] = -C;
    mat4x3 P = (K * Q) * IC;      // projection

    float min_z = 1.0;

    vec3 col = vec3(0);

    int n = 0;
    vec3[20] c;
    float[20] z;

    for (int i = 0; i < 20; i++)
    {
        vec3 q1 = P * v[int(f[i].x)] + 0.5;
        vec3 q2 = P * v[int(f[i].y)] + 0.5;
        vec3 q3 = P * v[int(f[i].z)] + 0.5;
        if (intri(uv, q1.xy, q2.xy, q3.xy))
        {
            mat3 A = mat3(q1.x, q1.y, 1, q2.x, q2.y, 1, q3.x, q3.y, 1);
            vec3 iv = X * inverse(A) * vec3(uv.x, uv.y, 1);
            c[n] = texture(iChannel0, iv.xy).xyz;
            z[n] = ((q1 + q2 + q3) / 3.0).z;
            n += 1;
        }
    }

    int i = 1;
    while (i < n) {
        float x = z[i];
        vec3 X = c[i];
        int j = i - 1;
        while (j >= 0 && z[j] > x) {
            z[j+1] = z[j];
            c[j+1] = c[j];
            j = j - 1;
        }
        z[j+1] = x;
        c[j+1] = X;
        i = i + 1;
    }

    for (int i = 0; i < n; i++)
        col = mix(
            col,
            c[i],
            4.*0.5/20.*abs(mod(iTime-20./4., 20.)-20./2.)-0.5+0.5
        );

    fragColor = vec4(col, 1);
}
