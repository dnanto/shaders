vec2 y_to_xy(vec2 uv) {
    return uv / (iResolution.xy / iResolution.y) * (iResolution.xy / iResolution.xy);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // set resolution
    vec2 uv = fragCoord / iResolution.y;

    // scene parameters
    Scene scene = frame_to_scene(iFrame);

    // lattice parameters
    int m = scene.m;
    float h = float(scene.h);
    float k = float(scene.k);
    Params p = mode_to_params(m, h, k);

    // calculate vertex coordinates
    vec2 t0 = vec2(0);
    vec2 t1 = mat2(p.hvec, p.kvec) * vec2(h, k);
    vec2 t2 = rotmat2(rad60) * t1;
    uv.x += t2.x < 0.0 ? t2.x : 0.0;

    if (iFrame < checkpoints[1])
        uv.x -= (iResolution.x / iResolution.y - t1.x) / 2.0;

    // set border
    float dw = p.R * WIDTH;
    if (m == MODE_HEX || m == MODE_DUALHEX || m == MODE_DUALRHOMBITRIHEX)
        p.R -= dw;

    // calculate hex coordinate
    mat2 b = mat2(p.hvec, p.kvec);
    vec2 hex = b * round(inverse(b) * uv);
    bool in_hex = in_reg(uv, hex, 6.0, p.R, p.theta);
    if (!in_hex)
        if (cross2(vec2(p.r, 0.5 * p.R), hex - uv) < 0.)
            hex += (uv.x > hex.x) ? p.kvec : -p.hvec;
        else
            hex += (uv.x > hex.x) ? p.hvec : -p.kvec;

    // cellular automata
    vec3 col_face = COLOR_FACE;
    vec3 col_vertex = COLOR_VERTEX;
    vec3 col_triangle = COLOR_TRIANGLE;
    vec3 col_line = COLOR_LINE;
    vec3 col_background = COLOR_BACKGROUND;

    if (in_hex || in_reg(uv, hex, 6.0, p.R, p.theta)) {
        /****/ if (iFrame < checkpoints[2]) {
            // nada
        } else if (iFrame < checkpoints[3]) {
            vec2 uv = fragCoord / iResolution.y;
            Params p = mode_to_params(m, h, k);
            uv.y -= 6.0 * 1.5 * p.R;
            float off = mod(floor(iTime / 0.1) * 2.0 * p.r, float(img_m + 5) * 2.0 * p.r);
            uv.x -= off;
            vec2 hex = uv_to_hex(uv, p);
            int ir = int(round(hex.y / (1.5 * p.R)));
            int ic = int(round((hex.x - mod(float(ir), 2.0) * p.r) / (2.0 * p.r)));
            if (0 <= ic && ir < img_m && ic < img_n) {
                if (img[15 * ir + ic] == 1) {
                    if (in_reg(uv, hex, 6.0, p.R, rad30)) {
                        col_face = cos(iTime + uv.xyx );
                        col_face.x = 0.0;
                    }
                }
            }

        } else if (iFrame < checkpoints[4]) {
            // set random initial state
            col_face = vec3(fract(random(iTime + hex * iTime)) <= 0.45 ? COLOR_ON : COLOR_FACE);
        } else {
            // get ON/OFF state of hexagonal neighborhood
            int nw = int(T(iChannel0, y_to_xy(hex + vec2(-(1.0 * p.r), +(1.5 * p.R)))).rgb == COLOR_ON);
            int ne = int(T(iChannel0, y_to_xy(hex + vec2(+(1.0 * p.r), +(1.5 * p.R)))).rgb == COLOR_ON);
            int wc = int(T(iChannel0, y_to_xy(hex + vec2(-(2.0 * p.r), 0.0000000000))).rgb == COLOR_ON);
            int cc = int(T(iChannel0, y_to_xy(hex + vec2(0.0000000000, 0.0000000000))).rgb == COLOR_ON);
            int ec = int(T(iChannel0, y_to_xy(hex + vec2(+(2.0 * p.r), 0.0000000000))).rgb == COLOR_ON);
            int sw = int(T(iChannel0, y_to_xy(hex + vec2(-(1.0 * p.r), -(1.5 * p.R)))).rgb == COLOR_ON);
            int se = int(T(iChannel0, y_to_xy(hex + vec2(+(1.0 * p.r), -(1.5 * p.R)))).rgb == COLOR_ON);
            int n = nw + ne + wc + ec + sw + se;
            // update state of current central cell
            // https://www.conwaylife.com/wiki/Rulestring
            // rule B2/S34
            if (cc == 1) col_face = vec3((n == 3 || n == 4) ? COLOR_ON : COLOR_FACE);
            else /*****/ col_face = vec3((n == 2) ? COLOR_ON : COLOR_FACE);
        }
    }
    if (col_face == COLOR_ON) {
        col_vertex = COLOR_ON;
        col_triangle = COLOR_ON;
        col_line = COLOR_ON;
        col_background = COLOR_ON;
    }
    vec3 col = col_background;

    // base hex-pattern colors
    if (in_hex || in_reg(uv, hex, 6.0, p.R, p.theta)) {
        col = col_face;
    }
    if (
        in_reg(uv, t0, 6.0, p.R, p.theta) ||
        in_reg(uv, t1, 6.0, p.R, p.theta) ||
        in_reg(uv, t2, 6.0, p.R, p.theta)
    ) {
        col = col_vertex;
    }

    // lattice colors
    float R3 = p.R * sqrt3 / 3.0;
    float r3 = p.R * sqrt3 / 6.0;
    float a = R3 + r3;
    switch (m) {
        case MODE_SNUBHEX:
        {
            if (!in_hex) {
                vec2 uv = uv;
                uv.x += mod(floor(uv.y / a), 2.0) * 0.5 * p.R;
                vec2 c = vec2(p.R * round(uv.x / p.R), a * floor(uv.y / a));
                if (distline(uv, c, +rad60) < dw ||
                    distline(uv, c, -rad60) < dw ||
                    abs(uv.y - a * round(uv.y / a)) < dw
                ) col = col_line;
            }
            break;
        }
        case MODE_RHOMBITRIHEX:
        {
            float R = p.R;
            float r = p.r;
            float dx = R + r + r;
            float dy = R + a + R + a + R;
            vec2 c = vec2(dx * round(uv.x / dx), dy * round(uv.y / dy));
            if (in_reg(uv, c + vec2(0, +(R + R3)), 3.0, R3, -rad90)                    ||
                in_reg(uv, c + vec2(0, -(R + R3)), 3.0, R3, +rad90)                    ||
                in_reg(uv, c + vec2(+(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, +rad90) ||
                in_reg(uv, c + vec2(-(r + R / 2.0), +(R / 2.0 + r3)), 3.0, R3, +rad90) ||
                in_reg(uv, c + vec2(+(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, -rad90) ||
                in_reg(uv, c + vec2(-(r + R / 2.0), -(R / 2.0 + r3)), 3.0, R3, -rad90)
            ) col = col_triangle;
            break;
        }
        case MODE_DUALTRIHEX:
        {
            if (in_reg(uv, hex, 3.0, p.R, p.theta)                  ||
                in_reg(uv, hex, 3.0, p.R, p.theta + radians(180.0))
            )
                col = in_hex ? col : col_triangle;
            else
                col = col_background;

            // if (distline(uv, hex, +rad60) < dw ||
            //     distline(uv, hex, -rad60) < dw ||
            //     abs(uv.y - hex.y) < dw
            //    )
            //     col = col_line;

            vec2 hex = b * round(inverse(b) * uv);
            if (cross2(vec2(p.r, 0.5 * p.R), hex - uv) < 0.)
                hex += (uv.x > hex.x) ? p.kvec : -p.hvec;
            else
                hex += (uv.x > hex.x) ? p.hvec : -p.kvec;
            if ( in_reg(uv, hex, 6.0, p.R / cos30 + dw, rad30) &&
                !in_reg(uv, hex, 6.0, p.R / cos30 - dw, rad30)
               )
                col = col_line;

            break;
        }
        case MODE_DUALSNUBHEX:
        {
            if (in_floret(uv, t0, p.R + R3) ||
                in_floret(uv, t1, p.R + R3) ||
                in_floret(uv, t2, p.R + R3)
               )
                col = col_vertex;
            else {
                bool in_hex = false;
                mat2 b = mat2(p.hvec * 2.0, p.kvec * 2.0);
                {
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv - p.hvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv + p.kvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (!in_hex) {
                    vec2 uv = uv + p.hvec + p.kvec;
                    vec2 hex = b * round(inverse(b) * uv);
                    in_hex = in_floret(uv, hex, p.R + R3);
                }
                if (in_hex) col = col_face;
            }
            break;
        }
        case MODE_DUALRHOMBITRIHEX:
        {
            if (distline(uv, hex, +rad60) <= dw ||
                distline(uv, hex, -rad60) <= dw ||
                abs(uv.y - hex.y) < dw
               ) {
                col = col_background;
            }
            break;
        }
    }

    vec3 rnd = vec3(cos(iTime));
    rnd.x = 0.0;
    if (in_tri(uv, vec2(0), t1, t2)) col = mix(rnd, col, 0.85);

    fragColor = vec4(col, 1.0);
}
