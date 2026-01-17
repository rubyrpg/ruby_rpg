# frozen_string_literal: true

def create_top_bar(font)
  top_bar = Engine::GameObject.create(
    name: "TopBar",
    components: [
      Engine::Components::UI::Rect.create(
        bottom_ratio: 1.0,
        bottom_offset: -50
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  Engine::GameObject.create(
    name: "TopBarLabel",
    parent: top_bar,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_ratio: 0.5,
        top_offset: 5,
        bottom_offset: 5
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "UI Test")
    ]
  )

  top_bar
end
