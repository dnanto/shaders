#define N   20.0
#define P   0.45
#define ON  0.75
#define OFF 0.25

#define cos30 cos(radians(30.0))
#define sqrt3 sqrt(3.0)

#define WIDTH 0.125

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

float random (vec2 st)
{
    // https://thebookofshaders.com/10/
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 uv_to_hex(vec2 uv, float R) {
    float r = R * cos30;
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

vec3 hex_display(vec2 uv, vec2 pos, float chr, float R, vec3 col) {
    float r = R * cos30;
    float theta = radians(30.0);
    float n = chr;
    for (int i = 0; i < 13; i++) {
        float q = floor(n / 2.0);
        if (mod(q, 2.0) == 1.0) {
            float ir = 0.0;
            float ic = 0.0;
            switch (i) {
                case  0:
                case  5:
                case  8:
                    ir = +2.0;
                    break;
                case  1:
                case  9:
                    ir = +1.0;
                    break;
                case  3:
                case 11:
                    ir = -1.0;;
                    break;
                case  4:
                case  7:
                case 12:
                    ir = -2.0;
                    break;
            }
            /**/ if (i <= 4) ic = -1.0;
            else if (i >= 8) ic = +1.0;
            float dx = ic * 2.0 * r + ir * r;
            float dy = ir * 1.5 * R;
            if (inreg(uv, pos + vec2(dx, dy), 6.0, R, theta)) {
                col = vec3(ON);
                break;
            }
        }
        n = q;
    }
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    // default to time varying pixel color
    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    // compute circular cell radius
    float R = 1.0 / N;
    float r = R * cos30;

    vec2 pos = uv_to_hex(vec2(0.5), R);


    col = hex_display(uv, pos, 16127., R, col);


    // output to screen
    fragColor = vec4(col, 1.0);
}
