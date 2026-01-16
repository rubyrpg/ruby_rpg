# frozen_string_literal: true

module Rendering
  class DepthDebugEffect
    include SinglePassEffect

    def initialize
      @material = Engine::Material.create(
        shader: Engine::Shader.create(
          vertex_path: './shaders/fullscreen_vertex.glsl',
          fragment_path: './shaders/post_process/depth_debug_frag.glsl'
        )
      )
    end
  end
end
