# frozen_string_literal: true

module ShrinkRacer
  module UIText
    def self.create(pos, rotation, size, text, components: [])
      font_path = "assets/arial.ttf"

      # Convert old position (x, y from bottom) to new Y-down offsets
      # Old system: y=0 at bottom, y increases upward
      # New system: top=0, bottom=height (Y-down)
      left_offset = pos[0]
      top_offset = Engine::Window.framebuffer_height - pos[1] - size

      Engine::GameObject.create(
        name: "Text",
        pos: Vector[0, 0, 0],
        scale: Vector[1, 1, 1],
        rotation: rotation,
        components: [
          Engine::Components::UI::Rect.create(
            left_offset: left_offset,
            right_ratio: 1.0,
            top_offset: top_offset,
            bottom_ratio: 1.0,
            bottom_offset: -size
          ),
          Engine::Components::UI::FontRenderer.create(font: Engine::Font.create(font_file_path: font_path), string: text),
          *components
        ])
    end
  end
end
