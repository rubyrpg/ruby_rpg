# frozen_string_literal: true

module Rendering
  class SSREffect
    include Effect

    def initialize(max_steps: 64, step_size: 0.1, thickness: 0.5)
      @material = Engine::Material.new(
        Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/ssr_frag.glsl'
        )
      )
      @material.set_float("maxSteps", max_steps.to_f)
      @material.set_float("stepSize", step_size)
      @material.set_float("thickness", thickness)
    end

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      # Clear textures hash to ensure consistent ordering
      @material.instance_variable_set(:@textures, nil)

      # Set textures - screen first (color texture at slot 0), then depth, then normal
      @material.set_texture("screenTexture", input_rt.texture)
      @material.set_texture("depthTexture", PostProcessingEffect.depth_texture)
      @material.set_texture("normalTexture", PostProcessingEffect.normal_texture)

      # Set camera matrices
      camera = Engine::Camera.instance
      @material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      @material.set_mat4("viewProj", camera.matrix)
      @material.set_vec3("cameraPos", camera.position)

      screen_quad.draw_with_material(@material)

      output_rt.unbind
    end
  end
end
