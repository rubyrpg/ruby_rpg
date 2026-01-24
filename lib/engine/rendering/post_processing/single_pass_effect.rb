# frozen_string_literal: true

module Rendering
  module SinglePassEffect
    include Effect

    attr_reader :material

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)
      Engine::GL.Disable(Engine::GL::DEPTH_TEST)

      material.set_runtime_texture("depthTexture", PostProcessingEffect.depth_texture)
      screen_quad.draw(material, input_rt.color_texture)
      output_rt
    end
  end
end
