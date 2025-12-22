# frozen_string_literal: true

module Cubes
  class MetalComputeShaderAnimator < Engine::Component
    def initialize(compute_shader, shared_textures)
      @compute_shader = compute_shader
      @shared_textures = shared_textures
      @time = 0.0
      @frame_count = 0
    end

    def update(delta_time)
      @time += delta_time
      @frame_count += 1

      # Dispatch Metal compute shader
      metal_textures = @shared_textures.map(&:metal_texture)
      @compute_shader.dispatch(
        @shared_textures.first.width,
        @shared_textures.first.height,
        1,
        textures: metal_textures,
        floats: { "u_time" => @time }
      )

      # Blit from IOSurface-backed RECT textures to regular 2D textures
      @shared_textures.each(&:blit_to_2d)
    end
  end
end
