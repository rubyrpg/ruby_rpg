# frozen_string_literal: true

module ShrinkRacer
  module Text
    def self.create(pos, rotation, size, text)
      Engine::GameObject.create(
        name: "Text",
        pos: pos,
        scale: Vector[1,1,1] * size,
        rotation: rotation,
        components: [
          Engine::Components::FontRenderer.create(font: Engine::Font.open_sans, string: text)
        ])
    end
  end
end
