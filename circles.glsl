void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float d = 1.0 / mod(iTime, 100.0);

    vec2 uv = fragCoord / iResolution.y;

    vec3 col = vec3(0.0);

    float r = d / 2.0;
    vec2 p = (1.0 + floor(uv / d)) * d - r;

    if (length(uv - p) < r)
        col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0,2,4));

    fragColor = vec4(col, 1.0);
}
