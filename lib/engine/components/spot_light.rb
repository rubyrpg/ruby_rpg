# frozen_string_literal: true

module Engine::Components
  class SpotLight < Engine::Component
    include Engine::MatrixHelpers

    serialize :range, :colour, :inner_angle, :outer_angle, :cast_shadows

    attr_accessor :range, :colour, :inner_angle, :outer_angle, :cast_shadows, :shadow_layer_index

    def awake
      @range ||= 300
      @colour ||= [1.0, 1.0, 1.0]
      @inner_angle ||= 12.5
      @outer_angle ||= 17.5
      @cast_shadows = false if @cast_shadows.nil?
      @shadow_layer_index = nil
      @cached_light_space_matrix = nil
    end

    def start
      SpotLight.spot_lights << self
    end

    def destroy!
      SpotLight.spot_lights.delete(self)
    end

    def inner_cutoff
      Math.cos(@inner_angle * Math::PI / 180.0)
    end

    def outer_cutoff
      Math.cos(@outer_angle * Math::PI / 180.0)
    end

    def shadow_near
      @range * 0.01
    end

    def shadow_far
      # Factor of 2 needed to match shadow range with spotlight attenuation range
      @range * 2.0
    end

    def direction
      game_object.local_to_world_direction(Vector[0, 0, 1]).normalize
    end

    def position
      game_object.world_pos
    end

    def light_space_matrix
      @cached_light_space_matrix ||= compute_light_space_matrix
    end

    def update(delta_time)
      # Clear cache each frame so matrix is recomputed if light moves
      @cached_light_space_matrix = nil
    end

    def compute_light_space_matrix
      light_pos = position
      light_dir = direction
      target = light_pos + light_dir

      # Choose up vector that's not parallel to light direction
      # When light points mostly along Y axis, use Z as up instead
      up = if light_dir[1].abs > 0.9
        Vector[0, 0, 1]
      else
        Vector[0, 1, 0]
      end

      view_matrix = look_at(light_pos, target, up)

      # Perspective projection based on spotlight cone angle
      fov = (@outer_angle * 2.0 + 5.0) * Math::PI / 180.0
      # near/far ratio affects depth precision
      proj_matrix = perspective(fov, 1.0, shadow_near, shadow_far)

      (proj_matrix * view_matrix).transpose
    end

    def self.spot_lights
      @spot_lights ||= []
    end
  end
end
