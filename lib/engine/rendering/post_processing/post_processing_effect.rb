# frozen_string_literal: true

module Rendering
  module PostProcessingEffect
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
        TintEffect.new(color: color, intensity: intensity)
      end

      def depth_of_field(focus_distance: 10.0, focus_range: 50.0, blur_amount: 3.0, near: 0.1, far: 1000.0)
        DepthOfFieldEffect.new(focus_distance: focus_distance, focus_range: focus_range, blur_amount: blur_amount, near: near, far: far)
      end

      def depth_debug
        DepthDebugEffect.new
      end

      def bloom(threshold: 0.7, intensity: 1.0, blur_passes: 2, blur_scale: 1.0)
        BloomEffect.new(threshold: threshold, intensity: intensity, blur_passes: blur_passes, blur_scale: blur_scale)
      end

      def ssr(max_steps: 64, step_size: 0.1, thickness: 0.5, ray_offset: 2.0)
        SSREffect.new(max_steps: max_steps, step_size: step_size, thickness: thickness, ray_offset: ray_offset)
      end
    end
  end
end
