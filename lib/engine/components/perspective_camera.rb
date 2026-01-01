# frozen_string_literal: true

module Engine::Components
  class PerspectiveCamera < Engine::Component
    include Engine::MatrixHelpers
    attr_reader :near, :far

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

    def inverse_vp_matrix
      # matrix is already transposed for OpenGL column-major format
      # inverse of A^T is (A^-1)^T, so matrix.inverse gives us the inverse in column-major
      @inverse_vp_matrix ||= matrix.inverse
    end

    def position
      game_object.pos
    end

    def projection
      fov_radians = @fov * Math::PI / 180.0
      perspective(fov_radians, @aspect, @near, @far)
    end

    def view_matrix
      right = game_object.right
      up = game_object.up
      forward = game_object.forward
      pos = game_object.pos

      Matrix[
        [right[0], right[1], right[2], -right.dot(pos)],
        [up[0], up[1], up[2], -up.dot(pos)],
        [forward[0], forward[1], forward[2], -forward.dot(pos)],
        [0, 0, 0, 1]
      ].transpose
    end

    def update(delta_time)
      if game_object.rotation != @rotation || game_object.pos != @pos || game_object.scale != @scale
        @matrix = nil
        @inverse_vp_matrix = nil
      end
      @rotation = game_object.rotation.dup
      @pos = game_object.pos.dup
      @scale = game_object.scale.dup
    end
  end
end
