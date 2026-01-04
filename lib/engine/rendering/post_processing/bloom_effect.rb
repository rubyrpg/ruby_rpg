# frozen_string_literal: true

module Rendering
  class BloomEffect
    include Effect

    def initialize(threshold: 0.7, intensity: 1.0, blur_passes: 2, blur_scale: 1.0)
      @threshold = threshold
      @intensity = intensity
      @blur_passes = blur_passes
      @blur_scale = blur_scale

      setup_materials
    end

    def apply(input_rt, output_rt, screen_quad)
      ensure_textures(input_rt.width, input_rt.height)
      GL.Disable(GL::DEPTH_TEST)

      # Pass 1: Extract bright pixels
      @ping.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      screen_quad.draw(@threshold_material, input_rt.color_texture)
      @ping.unbind

      # Pass 2+: Blur passes (ping-pong between internal textures)
      @blur_passes.times do
        # Horizontal blur
        @pong.bind
        GL.Clear(GL::COLOR_BUFFER_BIT)
        @blur_material.set_vec2("direction", [1.0, 0.0])
        screen_quad.draw(@blur_material, @ping.color_texture)
        @pong.unbind

        # Vertical blur
        @ping.bind
        GL.Clear(GL::COLOR_BUFFER_BIT)
        @blur_material.set_vec2("direction", [0.0, 1.0])
        screen_quad.draw(@blur_material, @pong.color_texture)
        @ping.unbind
      end

      # Pass 3: Combine original + bloom
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      @combine_material.set_runtime_texture("screenTexture", input_rt.color_texture)
      @combine_material.set_runtime_texture("bloomTexture", @ping.color_texture)
      screen_quad.draw_with_material(@combine_material)
      output_rt.unbind
      output_rt
    end

    private

    def setup_materials
      @threshold_material = Engine::Material.create(
        shader: Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/bloom_threshold_frag.glsl'
        )
      )
      @threshold_material.set_float("threshold", @threshold)

      @blur_material = Engine::Material.create(
        shader: Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/bloom_blur_frag.glsl'
        )
      )
      @blur_material.set_float("blurScale", @blur_scale)

      @combine_material = Engine::Material.create(
        shader: Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/bloom_combine_frag.glsl'
        )
      )
      @combine_material.set_float("intensity", @intensity)
    end

    def ensure_textures(width, height)
      if @ping.nil? || @ping.width != width || @ping.height != height
        @ping = RenderTexture.new(width, height)
        @pong = RenderTexture.new(width, height)
      end
    end
  end
end
