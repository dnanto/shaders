void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.y;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    float R = 0.25;
    float r = R / 2.0;

    uv.x += mod(floor((uv.y + r) / R), 2.0) * r;

    vec2 t = floor((uv + r) / R);
    vec2 p = t * R;

    col = length(uv - p) < r ? col : vec3(0);

    // Output to screen
    fragColor = vec4(col, 1.0);
}
