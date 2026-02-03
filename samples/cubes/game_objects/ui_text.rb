# frozen_string_literal: true

module Cubes
  module UIText
    def self.create(pos, rotation, size, text)
      Engine::GameObject.create(
        name: "UIText",
        pos: pos,
        scale: Vector[1, 1, 1] * size,
        rotation: rotation,
        components: [
          Engine::Components::UI::FontRenderer.create(font: Engine::Font.open_sans, string: text)
        ])
    end
  end
end
