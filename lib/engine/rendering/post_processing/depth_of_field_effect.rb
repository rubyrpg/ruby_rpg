# frozen_string_literal: true

module Rendering
  class DepthOfFieldEffect
    include SinglePassEffect

    def initialize(focus_distance: 0.5, focus_range: 0.1, blur_amount: 3.0)
      @material = Engine::Material.new(
        Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/dof_frag.glsl'
        )
      )
      @material.set_float("focusDistance", focus_distance)
      @material.set_float("focusRange", focus_range)
      @material.set_float("blurAmount", blur_amount)
    end
  end
end
