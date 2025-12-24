# frozen_string_literal: true

require 'opengl'
require 'glfw'
require 'concurrent'
require 'os'
require 'native_audio'

require_relative 'engine/autoloader'
require_relative "engine/debugging"
require_relative 'engine/rendering/render_texture'
require_relative 'engine/rendering/shadow_map_array'
require_relative 'engine/rendering/cubemap_shadow_map_array'
require_relative 'engine/rendering/screen_quad'
require_relative 'engine/rendering/post_processing_effect'
require_relative 'engine/rendering/bloom_effect'
require_relative 'engine/rendering/render_pipeline'
require_relative 'engine/rendering/instance_renderer'
require_relative 'engine/screenshoter'
require_relative 'engine/input'
require_relative "engine/quaternion"
require_relative 'engine/game_object'
require_relative 'engine/texture'
require_relative 'engine/material'
require_relative 'engine/mesh'
require_relative 'engine/standard_meshes/quad_mesh'
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
require_relative "engine/components/renderers/sprite_renderer"
require_relative "engine/components/renderers/ui_sprite_renderer"
require_relative "engine/components/ui_sprite_clickbox"
require_relative "engine/components/renderers/mesh_renderer"
require_relative "engine/components/renderers/font_renderer_base"
require_relative "engine/components/renderers/font_renderer"
require_relative "engine/components/renderers/ui_font_renderer"
require_relative "engine/components/point_light"
require_relative "engine/components/direction_light"
require_relative "engine/components/spot_light"
require_relative "engine/components/audio_source"

require_relative "engine/physics/physics_resolver"
require_relative 'engine/physics/collision'
require_relative "engine/physics/components/sphere_collider"
require_relative "engine/physics/components/cube_collider"
require_relative "engine/physics/components/rigidbody"

# Platform-specific compute shader implementations
if OS.mac?
  # Metal compute shaders (Mac)
  require_relative "engine/metal/metal_bindings"
  require_relative "engine/metal/device"
  require_relative "engine/metal/compute_shader"
  require_relative "engine/metal/compute_texture"
else
  # OpenGL compute shaders (Windows/Linux)
  require_relative "engine/opengl/compute_shader"
  require_relative "engine/opengl/compute_texture"
end

# Platform-agnostic compute shader factories
require_relative "engine/compute_shader"
require_relative "engine/compute_texture"

if OS.windows?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "glfw-3.4.bin.WIN64", "lib-static-ucrt", "glfw3.dll")))
elsif OS.mac?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "glfw-3.3.9.bin.MACOS", "lib-arm64", "libglfw.3.dylib")))
end
GLFW.Init

require_relative 'engine/engine'
