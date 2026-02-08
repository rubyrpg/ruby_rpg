# frozen_string_literal: true

module Cubes
  class SoundTest < Engine::Component
    def start
      audio = game_object.components.find { |c| c.is_a?(Engine::Components::AudioSource) }
      audio&.play
      audio&.looping = true
      audio&.set_reverb(room_size: 0.8, damping: 0.2, wet: 0.5, dry: 1.0)
    end
  end
end
