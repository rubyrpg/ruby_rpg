# frozen_string_literal: true

module Rendering
  class PostProcessingEffect
    attr_reader :material
    attr_accessor :enabled

    def initialize(material, enabled: true)
      @material = material
      @enabled = enabled
    end

    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      material.set_texture("depthTexture", self.class.depth_texture)
      screen_quad.draw(material, input_rt.texture)

      output_rt.unbind
    end

    class << self
      def add(effect)
        effects << effect
        effect
      end

      def remove(effect)
        effects.delete(effect)
      end

      def clear
        @effects = []
      end

      def apply_all(render_texture_a, render_texture_b, screen_quad)
        enabled_effects = effects.select(&:enabled)
        return render_texture_a if enabled_effects.empty?

        @depth_texture = render_texture_a.depth_texture
        @normal_texture = render_texture_a.normal_texture
        textures = [render_texture_a, render_texture_b]
        current_index = 0

        enabled_effects.each do |effect|
          input_rt = textures[current_index]
          output_rt = textures[1 - current_index]

          effect.apply(input_rt, output_rt, screen_quad)
          current_index = 1 - current_index
        end

        textures[current_index]
      end

      def depth_texture
        @depth_texture
      end

      def normal_texture
        @normal_texture
      end

      def effects
        @effects ||= []
      end

      # Built-in effects

      def tint(color: [1.0, 1.0, 1.0], intensity: 0.5)
        shader = Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/tint_frag.glsl'
        )
        material = Engine::Material.new(shader)
        material.set_vec4("tintColor", [color[0], color[1], color[2], intensity])
        new(material)
      end

      def depth_of_field(focus_distance: 0.5, focus_range: 0.1, blur_amount: 3.0)
        shader = Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/dof_frag.glsl'
        )
        material = Engine::Material.new(shader)
        material.set_float("focusDistance", focus_distance)
        material.set_float("focusRange", focus_range)
        material.set_float("blurAmount", blur_amount)
        new(material)
      end

      def depth_debug
        shader = Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/depth_debug_frag.glsl'
        )
        new(Engine::Material.new(shader))
      end

      def bloom(threshold: 0.7, intensity: 1.0, blur_passes: 2, blur_scale: 1.0)
        BloomEffect.new(threshold: threshold, intensity: intensity, blur_passes: blur_passes, blur_scale: blur_scale)
      end

      def debug_normals
        shader = Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/debug_normals_frag.glsl'
        )
        DebugNormalsEffect.new(Engine::Material.new(shader))
      end

      def ssr(max_steps: 64, step_size: 0.1, thickness: 0.5)
        shader = Engine::Shader.new(
          './shaders/fullscreen_vertex.glsl',
          './shaders/post_process/ssr_frag.glsl'
        )
        material = Engine::Material.new(shader)
        material.set_float("maxSteps", max_steps.to_f)
        material.set_float("stepSize", step_size)
        material.set_float("thickness", thickness)
        SSREffect.new(material)
      end
    end
  end

  class DebugNormalsEffect < PostProcessingEffect
    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      material.set_texture("normalTexture", PostProcessingEffect.normal_texture)
      screen_quad.draw(material, input_rt.texture)

      output_rt.unbind
    end
  end

  class SSREffect < PostProcessingEffect
    def apply(input_rt, output_rt, screen_quad)
      output_rt.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      # Clear textures hash to ensure consistent ordering
      material.instance_variable_set(:@textures, nil)

      # Set textures - screen first (color texture at slot 0), then depth, then normal
      material.set_texture("screenTexture", input_rt.texture)
      material.set_texture("depthTexture", PostProcessingEffect.depth_texture)
      material.set_texture("normalTexture", PostProcessingEffect.normal_texture)

      # Set camera matrices
      camera = Engine::Camera.instance
      material.set_mat4("inverseVP", camera.inverse_vp_matrix)
      material.set_mat4("viewProj", camera.matrix)
      material.set_vec3("cameraPos", camera.position)

      screen_quad.draw_with_material(material)

      output_rt.unbind
    end
  end
end
