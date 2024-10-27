# frozen_string_literal: true

module Engine::Components
  class OrthographicCamera < Engine::Component

    def initialize(width:, height:, far:)
      @width = width
      @height = height
      @far = far
      @near = 0

      Engine::Camera.instance = self
    end

    def destroy
      Engine::Camera.instance = nil if Engine::Camera.instance == self
    end

    def matrix
      @matrix ||=
        begin
          camera_pos = game_object.pos - game_object.forward * (@far / 2)
          Matrix[
            [right[0], up[0], -front[0], 0],
            [right[1], up[1], -front[1], 0],
            [right[2], up[2], -front[2], 0],
            [-camera_pos.dot(right), -camera_pos.dot(up), camera_pos.dot(front), 1]
          ]
        end
    end

    def update(delta_time)
      @right = nil if game_object.rotation != @rotation
      @up = nil if game_object.rotation != @rotation
      @front = nil if game_object.rotation != @rotation
      @matrix = nil if game_object.rotation.to_a != @rotation
      @rotation = game_object.rotation.to_a
    end

    private

    def right
      @right ||= game_object.right / (@width / 2)
    end

    def up
      @up ||= game_object.up / (@height / 2)
    end

    def front
      @front ||= game_object.forward / (@far / 2)
    end
  end
end
