# frozen_string_literal: true

module Engine::Components
  class PointLight < Engine::Component
    # Only 1 shadow-casting point light supported due to GLSL 330 sampler limitation
    NR_SHADOW_CASTING_POINT_LIGHTS = 1

    # Cubemap face directions: +X, -X, +Y, -Y, +Z, -Z
    CUBE_DIRECTIONS = [
      { dir: Vector[1, 0, 0],  up: Vector[0, -1, 0] },   # +X
      { dir: Vector[-1, 0, 0], up: Vector[0, -1, 0] },   # -X
      { dir: Vector[0, 1, 0],  up: Vector[0, 0, 1] },    # +Y
      { dir: Vector[0, -1, 0], up: Vector[0, 0, -1] },   # -Y
      { dir: Vector[0, 0, 1],  up: Vector[0, -1, 0] },   # +Z
      { dir: Vector[0, 0, -1], up: Vector[0, -1, 0] }    # -Z
    ].freeze

    attr_accessor :range, :colour, :cast_shadows
    attr_reader :shadow_map

    def initialize(range: 300, colour: [1.0, 1.0, 1.0], cast_shadows: false)
      @range = range
      @colour = colour
      @cast_shadows = cast_shadows
      @shadow_map = Rendering::CubemapShadowMap.new if cast_shadows
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

    def perspective(fov, aspect, near, far)
      tan_half_fov = Math.tan(fov / 2.0)

      Matrix[
        [1.0 / (aspect * tan_half_fov), 0, 0, 0],
        [0, 1.0 / tan_half_fov, 0, 0],
        [0, 0, -(far + near) / (far - near), -(2.0 * far * near) / (far - near)],
        [0, 0, -1, 0]
      ]
    end
  end
end
