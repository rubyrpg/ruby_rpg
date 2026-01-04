# frozen_string_literal: true

module Cubes
  class Spinner < Engine::Component
    serialize :speed

    def update(delta_time)
      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, @speed, 0] * delta_time)
    end
  end
end
