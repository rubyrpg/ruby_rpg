# frozen_string_literal: true

module Engine::Components
  class PointLight < Engine::Component
    attr_accessor :range, :colour

    def initialize(range: 300, colour: [1.0, 1.0, 1.0])
      @range = range
      @colour = colour
    end

    def start
      PointLight.point_lights << self
    end

    def destroy!
      PointLight.point_lights.delete(self)
    end

    def self.point_lights
      @point_lights ||= []
    end
  end
end