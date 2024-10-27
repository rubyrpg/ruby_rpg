#!/bin/bash

input_file=$1
output_file=$2

export BUILDING=true

ocran $input_file \
      **/*.png **/*.obj **/*.glsl **/*.vertex_data **/*.index_data **/*.json **/*.csv glfw-3.4.bin.WIN64/**/* src/**/*.rb \
      --output $output_file


