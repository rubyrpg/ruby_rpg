# frozen_string_literal: true

module Asteroids
  class ConstantDrift < Engine::Component
    def initialize(drift)
      @drift = drift
    end

    def update(delta_time)
      direction = game_object.local_to_world_direction(Vector[0, 1, 0]).normalize
      game_object.pos += direction * @drift * delta_time
    end
  end
end
