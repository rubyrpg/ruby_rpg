# frozen_string_literal: true

module Rendering
  class SSREffect
    include Effect

    def initialize(max_steps: 64, max_ray_distance: 50.0, thickness: 0.5, ray_offset: 2.0)
      @material = Engine::Material.new(
        Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/ssr_frag.glsl'
        )
      )
      @material.set_int("maxSteps", max_steps)
      @material.set_float("maxRayDistance", max_ray_distance)
      @material.set_float("thickness", thickness)
      @material.set_float("rayOffset", ray_offset)
    end

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      # Clear textures hash to ensure consistent ordering
      @material.instance_variable_set(:@textures, nil)

      # Set textures - screen first (color texture at slot 0), then depth, then normal
      @material.set_texture("screenTexture", input_rt.color_texture)
      @material.set_texture("depthTexture", PostProcessingEffect.depth_texture)
      @material.set_texture("normalTexture", PostProcessingEffect.normal_texture)

      # Set camera matrices and near/far planes
      camera = Engine::Camera.instance
      @material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      @material.set_mat4("viewProj", camera.matrix)
      @material.set_vec3("cameraPos", camera.position)
      @material.set_float("nearPlane", camera.near)
      @material.set_float("farPlane", camera.far)

      # Bind skybox cubemap for rays that miss geometry
      cubemap = RenderPipeline.skybox_cubemap
      @material.set_cubemap("skyboxCubemap", cubemap&.texture)

      screen_quad.draw_with_material(@material)

      output_rt.unbind
    end
  end
end
