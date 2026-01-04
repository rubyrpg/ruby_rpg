# frozen_string_literal: true

module Rendering
  class TintEffect
    include SinglePassEffect

    def initialize(color: [1.0, 1.0, 1.0], intensity: 0.5)
      @material = Engine::Material.create(
        shader: Engine::Shader.create(
          vertex_path: './shaders/fullscreen_vertex.glsl',
          fragment_path: './shaders/post_process/tint_frag.glsl'
        )
      )
      @material.set_vec4("tintColor", [color[0], color[1], color[2], intensity])
    end
  end
end
