# frozen_string_literal: true

module Cubes
  class SoundTest < Engine::Component
    def start
      audio = game_object.components.find { |c| c.is_a?(Engine::Components::AudioSource) }
      audio&.play
    end
  end
end
