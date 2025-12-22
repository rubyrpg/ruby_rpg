# frozen_string_literal: true

module Rendering
  class PostProcessingEffect
    attr_reader :material
    attr_accessor :enabled

    def initialize(material, enabled: true)
      @material = material
      @enabled = enabled
    end

    def apply(input_texture, output_framebuffer, screen_quad)
      output_framebuffer.bind
      GL.Clear(GL::COLOR_BUFFER_BIT)
      GL.Disable(GL::DEPTH_TEST)

      screen_quad.draw(material, input_texture)

      output_framebuffer.unbind
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

        textures = [render_texture_a, render_texture_b]
        current_index = 0

        enabled_effects.each do |effect|
          input_texture = textures[current_index].texture
          output_texture = textures[1 - current_index]

          effect.apply(input_texture, output_texture, screen_quad)
          current_index = 1 - current_index
        end

        textures[current_index]
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
    end
  end
end
