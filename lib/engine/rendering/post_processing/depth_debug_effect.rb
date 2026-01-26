# frozen_string_literal: true

module Rendering
  class DepthDebugEffect
    include SinglePassEffect

    def initialize
      @material = Engine::Material.create(
        shader: Engine::Shader.for(
          'fullscreen_vertex.glsl',
          'post_process/depth_debug_frag.glsl',
          source: :engine
        )
      )
    end
  end
end
