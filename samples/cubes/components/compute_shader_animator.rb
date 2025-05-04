# frozen_string_literal: true

module Cubes
  class ComputeShaderAnimator < Engine::Component
    def initialize(compute_shader, textures)
      @compute_shader = compute_shader
      @textures = textures
      @time = 0.0
    end

    def update(delta_time)
      @time += delta_time
      @compute_shader.dispatch(512, 512, 1, floats: {"u_time" => @time}, textures: @textures)
    end
  end
end
  