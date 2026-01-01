# frozen_string_literal: true

module Rendering
  module SinglePassEffect
    include Effect

    attr_reader :material

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      material.set_texture("depthTexture", PostProcessingEffect.depth_texture)
      screen_quad.draw(material, input_rt.color_texture)

      output_rt.unbind
      output_rt
    end
  end
end
