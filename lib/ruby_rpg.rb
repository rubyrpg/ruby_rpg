# frozen_string_literal: true

# Preload vendored DLLs on Windows before loading native extensions
if RUBY_PLATFORM =~ /mingw|mswin/
  require 'fiddle'
  glew_dll = File.expand_path('../vendor/glew-2.2.0-win32/bin/Release/x64/glew32.dll', __dir__)
  Fiddle.dlopen(glew_dll)
end

require_relative 'engine/gl'
require_relative 'engine/glfw'
require 'concurrent'
require 'os'
require 'native_audio'

require_relative 'engine/autoloader'
require_relative 'engine/serialization/serializable'
require_relative 'engine/serialization/object_serializer'
require_relative 'engine/serialization/graph_serializer'
require_relative 'engine/serialization/yaml_persistence'
require_relative 'engine/matrix_helpers'
require_relative "engine/debugging"
require_relative 'engine/rendering/render_texture'
require_relative 'engine/rendering/shadow_map_array'
require_relative 'engine/rendering/cubemap_shadow_map_array'
require_relative 'engine/rendering/screen_quad'
require_relative 'engine/rendering/post_processing/post_processing_effect'
require_relative 'engine/rendering/post_processing/effect'
require_relative 'engine/rendering/post_processing/single_pass_effect'
require_relative 'engine/rendering/post_processing/bloom_effect'
require_relative 'engine/rendering/post_processing/tint_effect'
require_relative 'engine/rendering/post_processing/depth_of_field_effect'
require_relative 'engine/rendering/post_processing/depth_debug_effect'
require_relative 'engine/rendering/post_processing/ssr_effect'
require_relative 'engine/rendering/post_processing/ssao_effect'
require_relative 'engine/rendering/skybox_cubemap'
require_relative 'engine/rendering/skybox_renderer'
require_relative 'engine/rendering/gpu_timer'
require_relative 'engine/rendering/render_pipeline'
require_relative 'engine/rendering/ui/stencil_manager'
require_relative 'engine/rendering/instance_renderer'
require_relative 'engine/screenshoter'
require_relative 'engine/input'
require_relative "engine/quaternion"
require_relative 'engine/game_object'
require_relative 'engine/texture'
require_relative 'engine/material'
require_relative 'engine/mesh'
require_relative 'engine/standard_meshes/quad_mesh'
require_relative 'engine/standard_objects/default_material'
require_relative 'engine/standard_objects/cube'
require_relative 'engine/standard_objects/sphere'
require_relative 'engine/standard_objects/plane'
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

require_relative "engine/ui/rect"
require_relative "engine/components/ui/rect"
require_relative "engine/components/ui/flex"
require_relative "engine/components/ui/sprite_renderer"
require_relative "engine/components/ui/sprite_clickbox"
require_relative "engine/components/orthographic_camera"
require_relative "engine/components/perspective_camera"
require_relative "engine/components/renderers/sprite_renderer"
require_relative "engine/components/sprite_animator"
require_relative "engine/components/renderers/mesh_renderer"
require_relative "engine/components/renderers/font_renderer_base"
require_relative "engine/components/renderers/font_renderer"
require_relative "engine/components/ui/font_renderer"
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
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "vendor", "glfw-3.4.bin.WIN64", "lib-static-ucrt", "glfw3.dll")))
elsif OS.mac?
  GLFW.load_lib(File.expand_path(File.join(__dir__, "..", "vendor", "glfw-3.3.9.bin.MACOS", "lib-arm64", "libglfw.3.dylib")))
elsif OS.linux?
  # TODO: Consider vendoring GLFW for Linux (like Mac/Windows) to avoid
  # requiring users to install libglfw3 manually
  GLFW.load_lib("libglfw.so.3")
end
GLFW.Init

require_relative 'engine/engine'
