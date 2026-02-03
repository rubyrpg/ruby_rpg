# frozen_string_literal: true

module Engine::Components
  class PerspectiveCamera < Engine::Component
    include Engine::MatrixHelpers

    serialize :fov, :aspect, :near, :far

    attr_reader :near, :far

    def awake
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
          world_pos = game_object.local_to_world_coordinate(Vector[0, 0, 0])

          transformation_matrix = Matrix[
            [right[0], right[1], right[2], -right.dot(world_pos)],
            [up[0], up[1], up[2], -up.dot(world_pos)],
            [forward[0], forward[1], forward[2], -forward.dot(world_pos)],
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
      game_object.local_to_world_coordinate(Vector[0, 0, 0])
    end

    def projection
      fov_radians = @fov * Math::PI / 180.0
      perspective(fov_radians, @aspect, @near, @far)
    end

    def view_matrix
      right = game_object.right
      up = game_object.up
      forward = game_object.forward
      world_pos = game_object.local_to_world_coordinate(Vector[0, 0, 0])

      Matrix[
        [right[0], right[1], right[2], -right.dot(world_pos)],
        [up[0], up[1], up[2], -up.dot(world_pos)],
        [forward[0], forward[1], forward[2], -forward.dot(world_pos)],
        [0, 0, 0, 1]
      ].transpose
    end

    def update(delta_time)
      if game_object.world_transform_version != @cached_transform_version
        @matrix = nil
        @inverse_vp_matrix = nil
      end
      @cached_transform_version = game_object.world_transform_version
    end
  end
end
