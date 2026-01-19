# frozen_string_literal: true

def create_center_panel(font)
  center_panel = Engine::GameObject.create(
    name: "CenterPanel",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 0.25,
        right_ratio: 0.25,
        bottom_ratio: 0.25,
        top_ratio: 0.25,
        z_layer: 10
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.1, 0.3, 0.5, 0.9))
    ]
  )

  # Nested box with 20px margin
  inner_panel = Engine::GameObject.create(
    name: "CenterPanelInner",
    parent: center_panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 20,
        right_offset: 20,
        bottom_offset: 20,
        top_offset: 20
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.5, 0.7))
    ]
  )

  # Large title
  Engine::GameObject.create(
    name: "LargeText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_offset: 0,
        bottom_ratio: 1.0, bottom_offset: -60
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Large Title")
    ]
  )

  # Medium text
  Engine::GameObject.create(
    name: "MediumText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 0.5, top_offset: -10,
        bottom_ratio: 0.5, bottom_offset: -30
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Medium text here")
    ]
  )

  # Small text
  Engine::GameObject.create(
    name: "SmallText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 1.0, top_offset: -30,
        bottom_offset: 0
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Small footer text")
    ]
  )

  center_panel
end
