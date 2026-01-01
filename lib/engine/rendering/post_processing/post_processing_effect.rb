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

      def apply_all(render_texture_a, render_texture_b, screen_quad, normal_buffer = nil, start_index: 0)
        @depth_texture = render_texture_a.depth_texture
        @normal_texture = normal_buffer || render_texture_a.normal_texture

        enabled_effects = effects.select(&:enabled)
        textures = [render_texture_a, render_texture_b]
        return textures[start_index] if enabled_effects.empty?
        current_index = start_index

        enabled_effects.each do |effect|
          input_rt = textures[current_index]
          output_rt = textures[1 - current_index]

          stage_name = "pp:#{effect.class.name.split('::').last}"
          GpuTimer.measure(stage_name) do
            effect.apply(input_rt, output_rt, screen_quad)
          end
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

      def ssr(max_steps: 64, max_ray_distance: 50.0, thickness: 0.5, ray_offset: 2.0)
        SSREffect.new(max_steps: max_steps, max_ray_distance: max_ray_distance, thickness: thickness, ray_offset: ray_offset)
      end
    end
  end
end
