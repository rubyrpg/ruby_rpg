# frozen_string_literal: true

module Asteroids
  module Text
    def self.create(pos, rotation, size, text, components: [])
      font_path = "assets/arial.ttf"
      Engine::GameObject.create(
        name: "Text",
        pos: pos,
        scale: Vector[1,1,1] * size,
        rotation: rotation,
        components: [
          Engine::Components::UIFontRenderer.create(font: Engine::Font.create(font_file_path: font_path), string: text),
          *components
        ])
    end
  end
end
