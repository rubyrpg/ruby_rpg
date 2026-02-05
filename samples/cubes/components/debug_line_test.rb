# frozen_string_literal: true

module Cubes
  class DebugLineTest < Engine::Component
    def update(delta_time)
      pos = game_object.world_pos

      # Draw XYZ axes from object position
      Engine::Debug.line(pos, pos + Vector[200, 0, 0], color: [1, 1, 1])  # X = red
      Engine::Debug.line(pos, pos + Vector[0, 200, 0], color: [0, 1, 0])  # Y = green
      Engine::Debug.line(pos, pos + Vector[0, 0, 200], color: [0, 0, 1])  # Z = blue

      # Draw a rotating line
      @angle = (@angle || 0) + delta_time * 90
      rad = @angle * Math::PI / 180
      Engine::Debug.line(
        pos,
        pos + Vector[Math.cos(rad) * 15, 5, Math.sin(rad) * 15],
        color: [1, 1, 0]  # yellow
      )
    end
  end
end
