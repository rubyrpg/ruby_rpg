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
        Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)
        Engine::GL.Disable(Engine::GL::DEPTH_TEST)

        camera = Engine::Camera.instance
        return input_rt unless camera

        material.set_mat4("inverseVP", camera.inverse_vp_matrix)
        material.set_vec3("cameraPos", camera.position)
        material.set_cubemap("skyboxCubemap", @skybox_cubemap&.texture)
        material.set_runtime_texture("depthTexture", input_rt.depth_texture)

        screen_quad.draw(material, input_rt.color_texture)
        output_rt
      end

      def cubemap
        @skybox_cubemap
      end

      private

      def material
        @material ||= Engine::Material.create(
          shader: Engine::Shader.create(
            vertex_path: './shaders/fullscreen_vertex.glsl',
            fragment_path: './shaders/post_process/skybox_frag.glsl'
          )
        )
      end
    end
  end
end
