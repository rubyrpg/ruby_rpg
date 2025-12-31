# frozen_string_literal: true

module Rendering
  class SkyboxRenderer
    class << self
      def set_colors(ground:, horizon:, sky:, ground_y: -0.3, horizon_y: 0.0, sky_y: 1.0)
        @ground_color = ground
        @horizon_color = horizon
        @sky_color = sky
        @ground_y = ground_y
        @horizon_y = horizon_y
        @sky_y = sky_y
        @skybox_cubemap&.invalidate
      end

      def render_cubemap
        @skybox_cubemap ||= SkyboxCubemap.new
        @skybox_cubemap.render_if_needed(
          @ground_color,
          @horizon_color,
          @sky_color,
          @ground_y,
          @horizon_y,
          @sky_y
        )
      end

      def draw(input_rt, alternate_rt, screen_quad)
        output_rt = alternate_rt

        output_rt.bind
        GL.Clear(GL::COLOR_BUFFER_BIT)
        GL.Disable(GL::DEPTH_TEST)

        camera = Engine::Camera.instance
        unless camera
          output_rt.unbind
          return input_rt
        end

        material.set_mat4("inverseVP", camera.inverse_vp_matrix)
        material.set_vec3("cameraPos", camera.position)
        material.set_cubemap("skyboxCubemap", @skybox_cubemap&.texture)
        material.set_texture("depthTexture", input_rt.depth_texture)

        screen_quad.draw(material, input_rt.color_texture)
        output_rt.unbind

        output_rt
      end

      def cubemap
        @skybox_cubemap
      end

      private

      def material
        @material ||= Engine::Material.new(
          Engine::Shader.new(
            './shaders/fullscreen_vertex.glsl',
            './shaders/post_process/skybox_frag.glsl'
          )
        )
      end
    end
  end
end
