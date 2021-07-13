// https://graphtoy.com/?
//   f1(x,t)=0.05&v1=false&
//   f2(x,t)=f1()%20*%20cos(radians(30.0))&v2=false&
//   f3(x,t)=0.5%20*%20f1()%20/%20f2()&v3=false&
//   f4(x,t)=x%20*%20f3()%20+%20floor(x%20/%20f2())%20*%20f1()&v4=true&
//   f5(x,t)=&v5=true&
//   f6(x,t)=&v6=true&
//   grid=true&
//   coords=0,0,1.3333333333333333

#define width 0.035

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
  return step(pct - width, st.y) - step(pct + width, st.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord / iResolution.y;

    float f1 = 0.15;
    float f2 = f1 * cos(radians(30.0));
    float f3 = 0.5 * f1 / f2;
    float f4 = p.x * f3 + floor(p.x / f2) * f1;

    vec3 col = 0.5 + 0.5 * cos(iTime + p.xyx + vec3(0, 2, 4));

    col = plot(p, f4) > 0.0 ? col : vec3(0);

    fragColor = vec4(col, 1.0);
}
