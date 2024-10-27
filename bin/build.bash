#!/bin/bash

input_file=$1
output_file=$2

export BUILDING=true

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
glfw_path=$parent_path/../glfw-3.4.bin.WIN64

ocran $input_file \
      **/*.png **/*.obj **/*.glsl **/*.vertex_data **/*.index_data **/*.json **/*.csv $glfw_path/**/* src/**/*.rb \
      --output $output_file
