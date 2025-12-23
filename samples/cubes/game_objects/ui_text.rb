# frozen_string_literal: true

module Cubes
  module UIText
    def self.create(pos, rotation, size, text)
      font_path = "assets/arial.ttf"
      Engine::GameObject.new(
        "UIText",
        pos: pos,
        scale: Vector[1, 1, 1] * size,
        rotation: rotation,
        components: [
          Engine::Components::UIFontRenderer.new(Engine::Font.new(font_path), text)
        ])
    end
  end
end
