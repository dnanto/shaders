// Buffer A

#define N   100.0
#define P   0.25
#define ON  0.75
#define OFF 0.25

vec2 uv_to_cell(vec2 uv)
{
    mat2 b = mat2(1.0 / N, 0.0, 0.0, 1.0 / N);
    return b * round(inverse(b) * uv);
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
    float r = 1.0 / N / 2.0;
    // calculate central cell coordinate
    vec2 cell = uv_to_cell(uv);
    // update cell state if it contains the uv
    if (distance(uv, cell) < r) {
        if (iFrame < 60) {
            col = vec3(fract(random(iTime + cell * iTime)) <= P ? ON : OFF);
        } else {
            // get ON/OFF state of Moore neighborhood
            // https://en.wikipedia.org/wiki/Moore_neighborhood
            float dx = 2.0 * r;
            float dy = 2.0 * r;
            int nw = int(texture(iChannel0, cell + vec2(-dx, +dy)).rgb == vec3(ON));
            int nc = int(texture(iChannel0, cell + vec2(0.0, +dy)).rgb == vec3(ON));
            int ne = int(texture(iChannel0, cell + vec2(+dx, +dy)).rgb == vec3(ON));
            int wc = int(texture(iChannel0, cell + vec2(-dx, 0.0)).rgb == vec3(ON));
            int cc = int(texture(iChannel0, cell + vec2(0.0, 0.0)).rgb == vec3(ON));
            int ec = int(texture(iChannel0, cell + vec2(+dx, 0.0)).rgb == vec3(ON));
            int sw = int(texture(iChannel0, cell + vec2(-dx, -dy)).rgb == vec3(ON));
            int sc = int(texture(iChannel0, cell + vec2(0.0, -dy)).rgb == vec3(ON));
            int se = int(texture(iChannel0, cell + vec2(+dx, -dy)).rgb == vec3(ON));
            int n = nw + nc + ne + wc + ec + sw + sc + se;
            // update state of current central cell
            // https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules
            // Any live cell with two or three live neighbours survives.
            // All other live cells die in the next generation.
            // Any dead cell with three live neighbours becomes a live cell.
            // Similarly, all other dead cells stay dead.
            if (cc == 1) col = vec3((n == 2 || n == 3) ? ON : OFF);
            else /*******/ col = vec3((n == 3) ? ON : OFF);
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
