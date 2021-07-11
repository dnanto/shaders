// https://thebookofshaders.com/10/


float plot(vec2 st, float pct) {
  // The step() interpolation receives two parameters.
  // The first one is the limit or threshold, while
  // the second one is the value we want to check or pass.
  // Any value under the limit will return 0.0 while
  // everything above the limit will return 1.0.
  // 0 0 < < 0 - 0 =  0
  // 0 1 < > 0 - 1 = -1
  // 1 0 > < 1 - 0 =  1
  // 1 1 > > 1 - 1 =  0
  return step(pct - 0.005, st.y) - step(pct + 0.005, st.y);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.y;

    float cos30 = sqrt(3.0) / 2.0;
    float R = 0.25;
    float r = R * cos30;

    vec3 col = 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4));
    if (plot(p, r * floor(p.y / r)) > 0.0)
        col = vec3(0);
    for (float i = -8.0; i < 8.0; i++)
        if (plot(p, +cos30 / 0.5 * (p.x - i * R)) > 0.0)
            col = vec3(0);
    for (float i = 0.0; i < 12.0; i++)
        if (plot(p, -cos30 / 0.5 * (p.x - i * R)) > 0.0)
            col = vec3(0);


    fragColor = vec4(col, 1.0);
}
