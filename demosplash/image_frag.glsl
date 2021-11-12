vec2 uv_to_hex_R(vec2 uv, float R) {
    // get central hex coordinate
    float r = R * cos30;
    float theta = radians(30.0);
    vec2 hvec = vec2(2.0 * r, 0.0);
    vec2 kvec = vec2(r, 1.5 * R);
    mat2 b = mat2(hvec, kvec);
    vec2 cell = b * round(inverse(b) * uv);
    bool inhex = in_reg(uv, cell, 6.0, R, radians(theta));
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
    /****/ if (iFrame < checkpoints[0]) {
        vec2 uv = fragCoord / iResolution.y;

        float R = 1.0 / 18.0;
        float r = R * cos30;
        float B = R * 0.125;

        float off = floor(iTime / 0.1) * 2.0 * r;

        vec3 col = (
            in_reg(uv, uv_to_hex_R(uv, R), 6.0, R - B, radians(30.0)) ?
            vec3(0.25) :
            0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4))
        );

        uv.x += off;
        float dx = 2.0 * r;
        float dy = 1.5 * R;
        vec2 hex = uv_to_hex_R(uv, R);
        float ir = round(hex.y / dy);
        float ic = round((hex.x - ir * r) / dx / 5.0);
        float code = message[int(mod(ic, float(message.length())))];
        col = hex_display(uv, vec2(5.0 * ic * dx + 2.0 * dx, 0.5), code, R, B, col);
        fragColor = vec4(col, 1);
    } else if (iFrame < checkpoints[1]) {
        fragColor = T(iChannel0, fragCoord / iResolution.xy);
    } else {
        // set resolution
        vec2 uv = fragCoord / iResolution.y;
        // center
        uv -= vec2(iResolution.x / iResolution.y / 2.0, 0.5);

        // scene parameters
        Scene scene = frame_to_scene(iFrame);
        
        // lattice parameters
        int m = scene.m;
        float h = float(scene.h);
        float k = float(scene.k);
        Params p = mode_to_params(m, h, k);

        // calculate vertex coordinates
        vec2 t1 = mat2(p.hvec, p.kvec) * vec2(h, k);
        vec2 t2 = rotmat2(rad60) * t1;
        t1.x /= iResolution.x / iResolution.y;
        t2.x /= iResolution.x / iResolution.y;
        // triangular face
        mat3 X = mat3(
            0, 0, 1,
            t1.x, t1.y, 1,
            t2.x, t2.y, 1
        );

        // https://en.wikipedia.org/wiki/Camera_matrix
        // https://www.cs.cmu.edu/~16385/s17/Slides/11.1_Camera_matrix.pdf
        mat3 K = mat3(1);                           // calibration
        vec3 C = vec3(0);                           // translation
        mat3 Q = rotmat3(                           // rotation
            vec3(
                radians(mod(iTime, 360.0) * 10.0),
                radians(mod(iTime, 360.0) * 15.0),
                radians(mod(iTime, 360.0) * 20.0)
            )
        );
        mat4x3 IC = mat4x3(mat3(1));
        IC[3] = -C;
        mat4x3 P = (K * Q) * IC;                    // projection

        vec3 col = vec3(0);

        int n = 0;       // n-th color
        vec3[20] c;      // color value
        float[20] z;     // color depth
        int nf = 20;     // number of faces
        switch (scene.p) {
            case TET:
                nf = 4;
                break;
            case OCT:
                nf = 8;
                break;
            case ICO:
                nf = 20;
                break;
        }
        for (int i = 0; i < nf; i++)
        {
            // map face
            vec3 q1, q2, q3;
            switch (scene.p) {
                case TET:
                    q1 = P * TET_V[int(TET_F[i].x)]; q2 = P * TET_V[int(TET_F[i].y)]; q3 = P * TET_V[int(TET_F[i].z)];
                    break;
                case OCT:
                    q1 = P * OCT_V[int(OCT_F[i].x)]; q2 = P * OCT_V[int(OCT_F[i].y)]; q3 = P * OCT_V[int(OCT_F[i].z)];
                    break;
                case ICO:
                    q1 = P * ICO_V[int(ICO_F[i].x)]; q2 = P * ICO_V[int(ICO_F[i].y)]; q3 = P * ICO_V[int(ICO_F[i].z)];
                    break;
            }
            if (in_tri(uv, q1.xy, q2.xy, q3.xy))
            {
                mat3 A = mat3(
                    q1.x, q1.y, 1,
                    q2.x, q2.y, 1,
                    q3.x, q3.y, 1
                );
                // face centroid depth
                z[n] = ((q1 + q2 + q3) / 3.0).z;
                // https://stackoverflow.com/a/55550712
                // map lattice texture to face
                vec3 iv = X * inverse(A) * vec3(uv.x, uv.y, 1);
                iv.x -= t2.x < 0.0 ? t2.x : 0.0;
                c[n] = mix(texture(iChannel0, iv.xy).xyz, vec3(0), -z[n]);
                n += 1;
            }
        }

        // painter's algorithm
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
        for (int i = 0; i < n; i++) col = mix(col, c[i], 0.75);

        fragColor = vec4(col, 1);
    }
}
