# frozen_string_literal: true

module Rendering
  class DepthOfFieldEffect
    include SinglePassEffect

    def initialize(focus_distance: 10.0, focus_range: 50.0, blur_amount: 3.0, near: 0.1, far: 1000.0)
      @material = Engine::Material.new(
        Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/dof_frag.glsl'
        )
      )
      @material.set_float("focusDistance", focus_distance)
      @material.set_float("focusRange", focus_range)
      @material.set_float("blurAmount", blur_amount)
      @material.set_float("nearPlane", near)
      @material.set_float("farPlane", far)
    end
  end
end
