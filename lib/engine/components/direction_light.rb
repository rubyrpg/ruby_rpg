# frozen_string_literal: true

module Engine::Components
  class DirectionLight < Engine::Component
    include Engine::MatrixHelpers

    attr_reader :colour, :cast_shadows, :shadow_distance
    attr_accessor :shadow_layer_index

    def initialize(colour: [1.0, 1.0, 1.0], cast_shadows: true, shadow_distance: 50.0)
      @colour = colour
      @cast_shadows = cast_shadows
      @shadow_distance = shadow_distance
      @shadow_layer_index = nil  # Set by RenderPipeline when rendering shadows
      @cached_light_space_matrix = nil
      @cache_key = nil
    end

    def colour=(value)
      @colour = value
    end

    def cast_shadows=(value)
      @cast_shadows = value
      invalidate_cache
    end

    def shadow_distance=(value)
      @shadow_distance = value
      invalidate_cache
    end

    def start
      DirectionLight.direction_lights << self
    end

    def destroy!
      DirectionLight.direction_lights.delete(self)
    end

    def direction
      game_object.forward.normalize
    end

    def light_space_matrix
      current_key = compute_cache_key
      if @cached_light_space_matrix && @cache_key == current_key
        return @cached_light_space_matrix
      end

      @cache_key = current_key
      @cached_light_space_matrix = compute_light_space_matrix
    end

    def self.direction_lights
      @direction_lights ||= []
    end

    private

    def invalidate_cache
      @cached_light_space_matrix = nil
      @cache_key = nil
    end

    def compute_cache_key
      camera_pos = Engine::Camera.instance&.position || Vector[0, 0, 0]
      light_dir = direction
      [camera_pos[0], camera_pos[1], camera_pos[2],
       light_dir[0], light_dir[1], light_dir[2],
       @shadow_distance]
    end

    def compute_light_space_matrix
      light_dir = direction

      # Center shadow frustum on the main camera's position
      center = Engine::Camera.instance&.position || Vector[0, 0, 0]

      # Position the light "camera" far back along the light direction from center
      light_pos = center - light_dir * @shadow_distance

      # Choose up vector that isn't parallel to light direction
      up = if light_dir[1].abs > 0.9
        Vector[0, 0, 1]
      else
        Vector[0, 1, 0]
      end

      # Create view matrix looking from light position toward center
      view_matrix = look_at(light_pos, center, up)

      # Orthographic projection covering the shadow area
      half_size = @shadow_distance
      proj_matrix = ortho(-half_size, half_size, -half_size, half_size, 0.1, @shadow_distance * 2)

      (proj_matrix * view_matrix).transpose
    end
  end
end
