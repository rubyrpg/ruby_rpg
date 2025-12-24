# frozen_string_literal: true

module Engine::Components
  class DirectionLight < Engine::Component
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
      # Position the light "camera" far back along the light direction
      light_pos = -light_dir * @shadow_distance

      # Create view matrix looking from light position toward origin
      view_matrix = look_at(light_pos, Vector[0, 0, 0], Vector[0, 1, 0])

      # Orthographic projection covering the shadow area
      half_size = @shadow_distance
      proj_matrix = ortho(-half_size, half_size, -half_size, half_size, 0.1, @shadow_distance * 2)

      proj_matrix * view_matrix
    end

    def self.direction_lights
      @direction_lights ||= []
    end

    private

    def look_at(eye, center, up)
      f = (center - eye).normalize
      s = f.cross(up).normalize
      u = s.cross(f)

      Matrix[
        [s[0], s[1], s[2], -s.dot(eye)],
        [u[0], u[1], u[2], -u.dot(eye)],
        [-f[0], -f[1], -f[2], f.dot(eye)],
        [0, 0, 0, 1]
      ]
    end

    def ortho(left, right, bottom, top, near, far)
      Matrix[
        [2.0 / (right - left), 0, 0, -(right + left) / (right - left)],
        [0, 2.0 / (top - bottom), 0, -(top + bottom) / (top - bottom)],
        [0, 0, -2.0 / (far - near), -(far + near) / (far - near)],
        [0, 0, 0, 1]
      ]
    end
  end
end