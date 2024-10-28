# frozen_string_literal: true

require 'opengl'
require 'glfw'
require 'concurrent'
require 'os'

require_relative 'engine/autoloader'
require_relative "engine/debugging"
require_relative 'engine/rendering/render_pipeline'
require_relative 'engine/rendering/instance_renderer'
require_relative 'engine/screenshoter'
require_relative 'engine/input'
require_relative "engine/quaternion"
require_relative 'engine/game_object'
require_relative 'engine/texture'
require_relative 'engine/material'
require_relative 'engine/mesh'
require_relative "engine/font"
require_relative 'engine/path'
require_relative 'engine/polygon_mesh'
require_relative 'engine/importers/obj_file'
require_relative 'engine/tangent_calculator'
require_relative 'engine/shader'
require_relative 'engine/component'
require_relative "engine/camera"
require_relative "engine/window"
require_relative "engine/video_mode"
require_relative "engine/cursor"

require_relative "engine/components/orthographic_camera"
require_relative "engine/components/perspective_camera"
require_relative "engine/components/sprite_renderer"
require_relative "engine/components/ui_sprite_renderer"
require_relative "engine/components/mesh_renderer"
require_relative "engine/components/font_renderer"
require_relative "engine/components/ui_font_renderer"
require_relative "engine/components/point_light"
require_relative "engine/components/direction_light"

require_relative "engine/physics/physics_resolver"
require_relative 'engine/physics/collision'
require_relative "engine/physics/components/sphere_collider"
require_relative "engine/physics/components/cube_collider"
require_relative "engine/physics/components/rigidbody"

if OS.windows?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "glfw-3.4.bin.WIN64", "lib-static-ucrt", "glfw3.dll")))
elsif OS.mac?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "glfw-3.3.9.bin.MACOS", "lib-arm64", "libglfw.3.dylib")))
end
GLFW.Init

require_relative 'engine/engine'
