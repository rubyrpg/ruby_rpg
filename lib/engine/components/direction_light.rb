# frozen_string_literal: true

module Engine::Components
  class DirectionLight < Engine::Component
    attr_accessor :colour

    def initialize(colour: [1.0, 1.0, 1.0])
      @colour = colour
    end

    def start
      DirectionLight.direction_lights << self
    end

    def destroy!
      DirectionLight.direction_lights.delete(self)
    end

    def self.direction_lights
      @direction_lights ||= []
    end
  end
end