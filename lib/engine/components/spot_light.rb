# frozen_string_literal: true

module Engine::Components
  class SpotLight < Engine::Component
    attr_accessor :range, :colour, :inner_angle, :outer_angle

    def initialize(range: 300, colour: [1.0, 1.0, 1.0], inner_angle: 12.5, outer_angle: 17.5)
      @range = range
      @colour = colour
      @inner_angle = inner_angle
      @outer_angle = outer_angle
    end

    def start
      SpotLight.spot_lights << self
    end

    def destroy!
      SpotLight.spot_lights.delete(self)
    end

    def inner_cutoff
      Math.cos(@inner_angle * Math::PI / 180.0)
    end

    def outer_cutoff
      Math.cos(@outer_angle * Math::PI / 180.0)
    end

    def self.spot_lights
      @spot_lights ||= []
    end
  end
end
