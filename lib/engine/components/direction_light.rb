# frozen_string_literal: true

module Engine::Components
  class DirectionLight < Engine::Component
    include Engine::MatrixHelpers

    attr_accessor :colour, :cast_shadows, :shadow_distance, :shadow_layer_index

    def initialize(colour: [1.0, 1.0, 1.0], cast_shadows: true, shadow_distance: 50.0)
      @colour = colour
      @cast_shadows = cast_shadows
      @shadow_distance = shadow_distance
      @shadow_layer_index = nil  # Set by RenderPipeline when rendering shadows
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

    def self.direction_lights
      @direction_lights ||= []
    end
  end
end
