# frozen_string_literal: true

module Engine::Components
  class OrthographicCamera < Engine::Component
    include Engine::MatrixHelpers
    attr_reader :near, :far

    serialize :width, :height, :far

    def awake
      @near ||= 0
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
          world_pos = game_object.world_pos

          view_matrix = Matrix[
            [right[0], right[1], right[2], -right.dot(world_pos)],
            [up[0], up[1], up[2], -up.dot(world_pos)],
            [forward[0], forward[1], forward[2], -forward.dot(world_pos)],
            [0, 0, 0, 1]
          ]

          (projection * view_matrix).transpose
        end
    end

    def inverse_vp_matrix
      @inverse_vp_matrix ||= matrix.inverse
    end

    def position
      game_object.world_pos
    end

    def projection
      half_w = @width / 2.0
      half_h = @height / 2.0
      ortho(-half_w, half_w, -half_h, half_h, @near, @far)
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
