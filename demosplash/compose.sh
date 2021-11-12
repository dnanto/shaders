#!/usr/bin/env bash

declare -a buffer_i=("buffer_a_frag.glsl" "image_frag.glsl")
declare -a buffer_o=("shader_a_frag.glsl" "shader_b_frag.glsl")

for idx in "${!buffer_i[@]}"
do
echo "${buffer_i[$idx]} -> ${buffer_o[$idx]}"
{
  cat \
<<PARA
#version 410 core
out vec4 fragColor;
#define fragCoord gl_FragCoord.xy
// #define iResolution vec2(1280.0, 720.0)
uniform vec2 iResolution;
uniform int iFrame;
uniform float iTime;
uniform sampler2D iChannel0;
PARA
  echo
  cat common_frag.glsl
  echo
  sed "s/mainImage(out vec4 fragColor, in vec2 fragCoord)/main()/" "${buffer_i[$idx]}"
} > "${buffer_o[$idx]}"
done
