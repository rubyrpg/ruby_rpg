# frozen_string_literal: true

module ShrinkRacer
  module Text
    def self.create(pos, rotation, size, text)
      font_path = "assets/arial.ttf"
      Engine::GameObject.create(
        name: "Text",
        pos: pos,
        scale: Vector[1,1,1] * size,
        rotation: rotation,
        components: [
          Engine::Components::FontRenderer.create(font: Engine::Font.create(font_file_path: font_path), string: text)
        ])
    end
  end
end
