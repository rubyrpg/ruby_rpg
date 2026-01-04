# frozen_string_literal: true

module ShrinkRacer
  module UIText
    def self.create(pos, rotation, size, text, components: [])
      font_path = "assets/arial.ttf"

      Engine::GameObject.create(
        name: "Text",
        pos: pos,
        scale: Vector[1,1,1] * size,
        rotation: rotation,
        components: [
          Engine::Components::UIFontRenderer.new(Engine::Font.new(font_path), text),
          *components
        ])
    end
  end
end
