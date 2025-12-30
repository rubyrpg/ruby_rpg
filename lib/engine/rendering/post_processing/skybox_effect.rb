# frozen_string_literal: true

module Rendering
  class SkyboxEffect
    include SinglePassEffect

    def initialize
      @material = Engine::Material.new(
        Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/skybox_frag.glsl'
        )
      )
    end

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      # Get camera for inverse VP matrix
      camera = Engine::Camera.instance
      return unless camera

      @material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      @material.set_vec3("cameraPos", camera.position)

      # Bind skybox cubemap
      cubemap = RenderPipeline.skybox_cubemap
      @material.set_cubemap("skyboxCubemap", cubemap&.texture)

      @material.set_texture("depthTexture", PostProcessingEffect.depth_texture)
      screen_quad.draw(@material, input_rt.color_texture)

      output_rt.unbind
    end
  end
end
