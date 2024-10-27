# frozen_string_literal: true

module Engine::Components
  class PerspectiveCamera < Engine::Component
    def initialize(fov:, aspect:, near:, far:)
      @fov = fov
      @aspect = aspect
      @near = near
      @far = far

      Engine::Camera.instance = self
    end

    def destroy
      Engine::Camera.instance = nil if Engine::Camera.instance == self
    end

    def matrix
      @matrix ||=
        begin
          right = game_object.right
          up = game_object.up
          forward = game_object.forward

          transformation_matrix = Matrix[
            [right[0], right[1], right[2], -right.dot(game_object.pos)],
            [up[0], up[1], up[2], -up.dot(game_object.pos)],
            [forward[0], forward[1], forward[2], -forward.dot(game_object.pos)],
            [0, 0, 0, 1]
          ]

          (projection * transformation_matrix).transpose
        end
    end

    def projection
      fov = @fov * Math::PI / 180
      Matrix[
        [1 / (Math.tan(fov / 2) * @aspect), 0, 0, 0],
        [0, 1 / Math.tan(fov / 2), 0, 0],
        [0, 0, (@far + @near) / (@near - @far), 2 * @far * @near / (@near - @far)],
        [0, 0, -1, 0]
      ]
    end

    def update(delta_time)
      @matrix = nil if game_object.rotation != @rotation || game_object.pos != @pos || game_object.scale != @scale
      @rotation = game_object.rotation.dup
      @pos = game_object.pos.dup
      @scale = game_object.scale.dup
    end
  end
end
