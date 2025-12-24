# frozen_string_literal: true

module Engine::Components
  class PointLight < Engine::Component
    include Engine::MatrixHelpers

    NR_SHADOW_CASTING_POINT_LIGHTS = 4

    # Cubemap face directions: +X, -X, +Y, -Y, +Z, -Z
    CUBE_DIRECTIONS = [
      { dir: Vector[1, 0, 0],  up: Vector[0, -1, 0] },   # +X
      { dir: Vector[-1, 0, 0], up: Vector[0, -1, 0] },   # -X
      { dir: Vector[0, 1, 0],  up: Vector[0, 0, 1] },    # +Y
      { dir: Vector[0, -1, 0], up: Vector[0, 0, -1] },   # -Y
      { dir: Vector[0, 0, 1],  up: Vector[0, -1, 0] },   # +Z
      { dir: Vector[0, 0, -1], up: Vector[0, -1, 0] }    # -Z
    ].freeze

    attr_accessor :range, :colour, :cast_shadows, :shadow_layer_index

    def initialize(range: 300, colour: [1.0, 1.0, 1.0], cast_shadows: false)
      @range = range
      @colour = colour
      @cast_shadows = cast_shadows
      @shadow_layer_index = nil
    end

    def start
      PointLight.point_lights << self
    end

    def destroy!
      PointLight.point_lights.delete(self)
    end

    def update(delta_time)
      @cached_light_space_matrices = nil if @cast_shadows
    end

    def position
      game_object.local_to_world_coordinate(Vector[0, 0, 0])
    end

    def shadow_near
      @range * 0.01
    end

    def shadow_far
      @range * 2.0
    end

    def light_space_matrices
      @cached_light_space_matrices ||= compute_light_space_matrices
    end

    def self.point_lights
      @point_lights ||= []
    end

    def self.shadow_casting_lights
      point_lights.select(&:cast_shadows).take(NR_SHADOW_CASTING_POINT_LIGHTS)
    end

    private

    def compute_light_space_matrices
      light_pos = position
      proj = perspective(Math::PI / 2.0, 1.0, shadow_near, shadow_far)

      CUBE_DIRECTIONS.map do |face|
        target = light_pos + face[:dir]
        view = look_at(light_pos, target, face[:up])
        (proj * view).transpose
      end
    end
  end
end
