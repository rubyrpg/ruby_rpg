# frozen_string_literal: true

module Cubes
  class Spinner < Engine::Component
    def initialize(speed = 90)
      @speed = speed
    end

    def update(delta_time)
      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, @speed, 0] * delta_time)
    end
  end
end
