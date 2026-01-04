# frozen_string_literal: true

module ShrinkRacer
  class Spinner < Engine::Component
    def awake
      @current_time ||= 0.0
    end

    def update(delta_time)
      @current_time += delta_time
      game_object.rotation *= Engine::Quaternion.from_euler(Vector[0, 360, 0] * delta_time)
      game_object.pos = Vector[0, Math.sin(@current_time * 2) * 0.05 + 0.05, 0]
    end
  end
end
