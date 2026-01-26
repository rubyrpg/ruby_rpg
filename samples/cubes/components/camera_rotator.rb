# frozen_string_literal: true

module Cubes
  class CameraRotator < Engine::Component
    ROTATION_SPEED = 60
    MOVE_SPEED = 50

    def start
      Engine::Cursor.disable
    end

    def update(delta_time)
      mouse_delta = Engine::Input.mouse_delta
      game_object.rotate_around(Vector[1, 0, 0], mouse_delta[1] * ROTATION_SPEED * delta_time)
      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, mouse_delta[0], 0] * ROTATION_SPEED * delta_time)

      if Engine::Input.key?(Engine::Input::KEY_A)
        game_object.pos -= game_object.right * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(Engine::Input::KEY_D)
        game_object.pos += game_object.right * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(Engine::Input::KEY_W)
        game_object.pos -= Vector[game_object.forward[0], 0, game_object.forward[2]].normalize * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(Engine::Input::KEY_S)
        game_object.pos += Vector[game_object.forward[0], 0, game_object.forward[2]].normalize * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(Engine::Input::KEY_Q)
        game_object.pos -= Vector[0, 1, 0] * MOVE_SPEED * delta_time
      end
      if Engine::Input.key?(Engine::Input::KEY_E)
        game_object.pos += Vector[0, 1, 0] * MOVE_SPEED * delta_time
      end
    end
  end
end
