# frozen_string_literal: true

module Cubes
  class SpotlightController < Engine::Component
    MOVE_SPEED = 30

    def update(delta_time)
      if Engine::Input.key?(GLFW::KEY_LEFT)
        game_object.pos -= Vector[1, 0, 0] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(GLFW::KEY_RIGHT)
        game_object.pos += Vector[1, 0, 0] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(GLFW::KEY_UP)
        game_object.pos -= Vector[0, 0, 1] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(GLFW::KEY_DOWN)
        game_object.pos += Vector[0, 0, 1] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(GLFW::KEY_PAGE_UP)
        game_object.pos += Vector[0, 1, 0] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(GLFW::KEY_PAGE_DOWN)
        game_object.pos -= Vector[0, 1, 0] * MOVE_SPEED * delta_time
      end
    end
  end
end
