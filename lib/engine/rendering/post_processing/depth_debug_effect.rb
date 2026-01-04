# frozen_string_literal: true

module Rendering
  class DepthDebugEffect
    include SinglePassEffect

    def initialize
      @material = Engine::Material.create(
        shader: Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/depth_debug_frag.glsl'
        )
      )
    end
  end
end
