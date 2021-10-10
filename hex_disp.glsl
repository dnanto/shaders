#define N   9.0
#define ON  0.75
#define OFF 0.25
#define COS30 cos(radians(30.0))
#define WIDTH 0.125

float hex_codes[49] = float[] (
    16127.0, 12735.0, 09087.0, 10681.0, 16313.0, 11263.0, 19199.0, 14719.0, 16063.0, 14527.0,
    12289.0, 16145.0, 14015.0, 08511.0, 15549.0, 14521.0, 14777.0, 03839.0, 16071.0, 18617.0,
    13287.0, 10687.0, 14649.0, 16191.0, 14617.0, 23709.0, 14007.0, 16263.0, 10227.0, 16255.0,
    15873.0, 12283.0, 16363.0, 16015.0, 15343.0, 15359.0, 15939.0, 16383.0, 16079.0, 08481.0,
    18569.0, 16425.0, 11777.0, 20219.0, 08193.0, 16391.0, 17927.0, 16767.0, 16193.0
);

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

vec3 hex_display(vec2 uv, vec2 pos, float chr, float R, float B, vec3 col) {
    // uv  the uv
    // pos the centreal display position
    // chr the character code to display
    // R   the hexagon circumradius
    // B   the border width
    // col the default color
    //
    //     0    5    8  -
    //    1         9    |
    //   2    6    A      > display bit mapping
    //  3         B      |
    // 4    7    C      -
    //
    // A a 16127          n 14521        0 16255  _ 08481
    // b   12735          o 14777        1 15873  - 18569
    // C c 09087 10681  P   03839        2 12283  : 16425
    //   d 16313          q 16071        3 16363  ! 11777
    // E   11263          r 18617        4 16015  ? 20219
    // F   19199        S   13287        5 15343  . 08193
    // G g 14719          t 10687        6 15359  ' 16391
    // H h 16063 14527  U u 16191 14649  7 15939  " 17927
    //   i 12289        V   14617        8 16383  [ 16767
    // J   16145          w 23709        9 16079  ] 16193
    // K   14015        X   14007
    // L   8511           y 16263
    // M   15549        Z   10227

    float r = R * COS30;
    float theta = radians(30.0);
    float n = chr;
    // set display according to bit index
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
            if (inreg(uv, pos + vec2(dx, dy), 6.0, R - B, theta)) {
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
    vec2 uv = fragCoord / iResolution.y;

    float R = 1.0 / N;
    float r = R * COS30;
    float B = R * WIDTH;

    vec2 hex = uv_to_hex(vec2(iResolution.x / iResolution.y / 2.0, 0.5), R);

    vec3 col = (
        inreg(uv, uv_to_hex(uv, R), 6.0, R - B, radians(30.0)) ?
        vec3(OFF) :
        0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4))
    );
    float code = hex_codes[int(mod(float(iFrame / 30), float(hex_codes.length())))];
    col = hex_display(uv, hex, code, R, B, col);

    fragColor = vec4(col, 1.0);
}
