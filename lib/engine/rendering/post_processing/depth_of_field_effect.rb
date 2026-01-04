# frozen_string_literal: true

module Rendering
  class DepthOfFieldEffect
    include Effect

    def initialize(focus_distance: 10.0, focus_range: 50.0, blur_amount: 3.0, near: 0.1, far: 1000.0)
      @focus_distance = focus_distance
      @focus_range = focus_range
      @blur_amount = blur_amount
      @near = near
      @far = far
    end

    def apply(rt_a, rt_b, screen_quad)
      GL.Disable(GL::DEPTH_TEST)

      blur_pass(rt_a, rt_b, [1.0, 0.0], screen_quad)  # horizontal
      blur_pass(rt_b, rt_a, [0.0, 1.0], screen_quad)  # vertical

      rt_a
    end

    def blur_pass(source_rt, dest_rt, direction, screen_quad)
      dest_rt.bind
      material.set_vec2("direction", direction)
      material.set_runtime_texture("screenTexture", source_rt.color_texture)
      material.set_runtime_texture("depthTexture", PostProcessingEffect.depth_texture)
      screen_quad.draw_with_material(material)
      dest_rt.unbind
    end

    private

    def material
      @material ||= begin
        mat = Engine::Material.create(
          shader: Engine::Shader.new(
            './shaders/fullscreen_vertex.glsl',
            './shaders/post_process/dof_blur_frag.glsl'
          )
        )
        mat.set_float("focusDistance", @focus_distance)
        mat.set_float("focusRange", @focus_range)
        mat.set_float("blurAmount", @blur_amount)
        mat.set_float("nearPlane", @near)
        mat.set_float("farPlane", @far)
        mat
      end
    end
  end
end
