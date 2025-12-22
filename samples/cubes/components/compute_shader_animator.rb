# frozen_string_literal: true

module Cubes
  class ComputeShaderAnimator < Engine::Component
    def initialize(compute_shader, compute_textures)
      @compute_shader = compute_shader
      @compute_textures = compute_textures
      @time = 0.0
    end

    def update(delta_time)
      @time += delta_time

      @compute_shader.dispatch(
        @compute_textures.first.width,
        @compute_textures.first.height,
        1,
        textures: @compute_textures,
        floats: { "u_time" => @time }
      )
    end
  end
end
