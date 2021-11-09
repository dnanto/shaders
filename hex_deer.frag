#define N   32.0
#define ON  vec3(0.75)
#define OFF vec3(0.25)
#define RAD30 radians(30.0)
#define COS30 cos(RAD30)
#define WIDTH 0.125

#define img_m 22
#define img_n 15
#define img int[img_m * img_n] (                   \
    0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0,   \
     0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  \
    0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0,   \
     0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  \
    0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,   \
     0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,  \
    0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0,   \
     0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,  \
    0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0,   \
     0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,  \
    0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0,   \
     1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0,  \
    0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0,   \
     0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,  \
    0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,   \
     0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,  \
    0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,   \
     1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,  \
    0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,   \
     0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,  \
    0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,   \
     0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0   \
)                                                  \

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
    // break-up regular polygon into triangles
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

vec2 uv_to_hex(vec2 uv, float R) {
    // get central hex coordinate
    float r = R * COS30;
    float theta = radians(30.0);
    vec2 hvec = vec2(2.0 * r, 0.0);
    vec2 kvec = vec2(r, 1.5 * R);
    mat2 b = mat2(hvec, kvec);
    vec2 cell = b * round(inverse(b) * uv);
    bool inhex = inreg(uv, cell, 6.0, R, radians(theta));
    // adjust hex coordinate due to overlap
    if (!inhex)
        if (cross2(vec2(r, 0.5 * R), cell - uv) < 0.)
            cell += (uv.x > cell.x) ? kvec : -hvec;
        else
            cell += (uv.x > cell.x) ? hvec : -kvec;
    return cell;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.y;

    float R = 1.0 / N;
    float r = R * COS30;
    float B = R * WIDTH;

    vec2 hex = uv_to_hex(uv, R);

    vec3 col = (
        inreg(uv, hex, 6.0, R - B, RAD30) ?
        OFF :
        0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4))
    );

    int ir = int(round(hex.y / (1.5 * R)));
    int ic = int(round((hex.x - mod(float(ir), 2.0) * r) / (2.0 * r)));
    if (ir < img_m && ic < img_n)
        if (img[15 * ir + ic] == 1)
            if (inreg(uv, hex, 6.0, R - B, RAD30))
                col = ON;


    fragColor = vec4(col, 1.0);
}
