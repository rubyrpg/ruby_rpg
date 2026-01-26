# frozen_string_literal: true

module Rendering
  class SSREffect
    include Effect

    def initialize(max_steps: 64, max_ray_distance: 50.0, thickness: 0.5, ray_offset: 2.0)
      @max_steps = max_steps
      @max_ray_distance = max_ray_distance
      @thickness = thickness
      @ray_offset = ray_offset
    end

    def apply(input_rt, output_rt, screen_quad)
      ensure_textures(input_rt.width, input_rt.height)

      camera = Engine::Camera.instance
      Engine::GL.Disable(Engine::GL::DEPTH_TEST)

      # Pass 1: Render SSR at half resolution
      @ssr_rt.bind
      Engine::GL.Disable(Engine::GL::BLEND)
      Engine::GL.ClearColor(0.0, 0.0, 0.0, 0.0)
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)

      ssr_material.set_runtime_texture("screenTexture", input_rt.color_texture)
      ssr_material.set_runtime_texture("depthTexture", PostProcessingEffect.depth_texture)
      ssr_material.set_runtime_texture("normalTexture", PostProcessingEffect.normal_texture)

      ssr_material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      ssr_material.set_mat4("viewProj", camera.matrix)
      ssr_material.set_vec3("cameraPos", camera.position)
      ssr_material.set_float("nearPlane", camera.near)
      ssr_material.set_float("farPlane", camera.far)

      cubemap = RenderPipeline.skybox_cubemap
      ssr_material.set_cubemap("skyboxCubemap", cubemap&.texture)

      screen_quad.draw_with_material(ssr_material)

      # Pass 2: Combine with scene at full resolution
      output_rt.bind
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)

      combine_material.set_runtime_texture("screenTexture", input_rt.color_texture)
      combine_material.set_runtime_texture("ssrTexture", @ssr_rt.color_texture)

      screen_quad.draw_with_material(combine_material)
      output_rt
    end

    private

    def ssr_material
      @ssr_material ||= begin
        material = Engine::Material.create(
          shader: Engine::Shader.for(
            'fullscreen_vertex.glsl',
            'post_process/ssr/frag.glsl',
            source: :engine
          )
        )
        material.set_int("maxSteps", @max_steps)
        material.set_float("maxRayDistance", @max_ray_distance)
        material.set_float("thickness", @thickness)
        material.set_float("rayOffset", @ray_offset)
        material
      end
    end

    def combine_material
      @combine_material ||= Engine::Material.create(
        shader: Engine::Shader.for(
          'fullscreen_vertex.glsl',
          'post_process/ssr/combine_frag.glsl',
          source: :engine
        )
      )
    end

    def ensure_textures(width, height)
      half_width = width / 2
      half_height = height / 2
      if @ssr_rt.nil? || @ssr_rt.width != half_width || @ssr_rt.height != half_height
        @ssr_rt = RenderTexture.new(half_width, half_height)
      end
    end
  end
end
