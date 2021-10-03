// Buffer A

#define N   100.0
#define P   0.45
#define ON  0.75
#define OFF 0.25

#define cos30 cos(radians(30.0))
#define sqrt3 sqrt(3.0)

#define width 0.125

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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    // default to time varying pixel color
    vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
    // compute circular cell radius
    float R = 1.0 / N;
    float r = R * cos30;
    // calculate central cell coordinate
    //// hexagonal grid basis
    vec2 hvec = vec2(2.0 * r, 0.0);
    vec2 kvec = vec2(r, 1.5 * R);
    float theta = 30.0;
    mat2 b = mat2(hvec, kvec);
    vec2 cell = b * round(inverse(b) * uv);
    //// substract some radius to add width
    R -= R * width;
    bool inhex = inreg(uv, cell, 6.0, R, radians(theta));
    //// adjust hex coordinate due to overlap
    if (!inhex)
        if (cross2(vec2(r, 0.5 * R), cell - uv) < 0.)
            cell += (uv.x > cell.x) ? kvec : -hvec;
        else
            cell += (uv.x > cell.x) ? hvec : -kvec;
    // update cell state if it contains the uv
    if (inhex || inreg(uv, cell, 6.0, R, radians(theta))) {
        if (iFrame < 60) {
            // set random initial state
            col = vec3(fract(random(iTime + cell * iTime)) <= P ? ON : OFF);
        } else {
            // get ON/OFF state of hexagonal neighborhood
            int nw = int(texture(iChannel0, cell + vec2(-(1.0 * r), +(1.5 * R))).rgb == vec3(ON));
            int ne = int(texture(iChannel0, cell + vec2(+(1.0 * r), +(1.5 * R))).rgb == vec3(ON));
            int wc = int(texture(iChannel0, cell + vec2(-(2.0 * r), (0.000000))).rgb == vec3(ON));
            int cc = int(texture(iChannel0, cell + vec2((0.000000), (0.000000))).rgb == vec3(ON));
            int ec = int(texture(iChannel0, cell + vec2(+(2.0 * r), (0.000000))).rgb == vec3(ON));
            int sw = int(texture(iChannel0, cell + vec2(-(1.0 * r), -(1.5 * R))).rgb == vec3(ON));
            int se = int(texture(iChannel0, cell + vec2(+(1.0 * r), -(1.5 * R))).rgb == vec3(ON));
            int n = nw + ne + wc + ec + sw + se;
            // update state of current central cell
            // https://www.conwaylife.com/wiki/Rulestring
            // rule B2/S34
            if (cc == 1) col = vec3((n == 3 || n == 4) ? ON : OFF);
            else /*****/ col = vec3((n == 2) ? ON : OFF);
        }
    }
    // output to screen
    fragColor = vec4(col, 1.0);
}

// Image

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // output Buffer A
    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);
}
