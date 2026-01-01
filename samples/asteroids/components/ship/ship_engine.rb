# frozen_string_literal: true

module Asteroids
  class ShipEngine < Engine::Component
    ACCELERATION = 400
    DECELERATION = 400
    MAX_SPEED = 400
    TURNING_SPEED = 300

    def initialize
      @speed = Vector[0, 0, 0]
    end

    def update(delta_time)
      direction = game_object.local_to_world_direction(Vector[0, 1, 0]).normalize
      @speed += direction * acceleration * delta_time
      clamp_speed
      game_object.pos += @speed * delta_time

      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, 0, torque * delta_time])
    end

    private

    def acceleration
      return ACCELERATION if Engine::Input.key?(GLFW::KEY_UP) || Engine::Input.key?(GLFW::KEY_W)
      return -DECELERATION if Engine::Input.key?(GLFW::KEY_DOWN) || Engine::Input.key?(GLFW::KEY_S)

      0
    end

    def clamp_speed
      if @speed.magnitude > MAX_SPEED
        @speed = @speed / @speed.magnitude * MAX_SPEED
      end
    end

    def torque
      total_torque = 0
      total_torque -= TURNING_SPEED if Engine::Input.key?(GLFW::KEY_LEFT) || Engine::Input.key?(GLFW::KEY_A)
      total_torque += TURNING_SPEED if Engine::Input.key?(GLFW::KEY_RIGHT) || Engine::Input.key?(GLFW::KEY_D)
      total_torque
    end
  end
end
