# frozen_string_literal: true

module Cubes
  module Light
    def self.create(pos, range, colour)
      Engine::GameObject.create(
        name: "Light",
        pos: pos,
        components: [
          Engine::Components::PointLight.create(range: range, colour: colour),
        ]
      )
    end
  end
end
