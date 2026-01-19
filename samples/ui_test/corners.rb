# frozen_string_literal: true

def create_corners
  # Red - top left
  Engine::GameObject.create(
    name: "TopLeft",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_ratio: 1.0, right_offset: -80,
        bottom_ratio: 1.0, bottom_offset: -80,
        top_offset: 10,
        z_layer: 25
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.8, 0.2, 0.2))
    ]
  )

  # Green - top right
  Engine::GameObject.create(
    name: "TopRight",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 1.0, left_offset: -80,
        right_offset: 10,
        bottom_ratio: 1.0, bottom_offset: -80,
        top_offset: 10,
        z_layer: 25
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.8, 0.2))
    ]
  )

  # Blue - bottom left
  Engine::GameObject.create(
    name: "BottomLeft",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_ratio: 1.0, right_offset: -80,
        bottom_offset: 10,
        top_ratio: 1.0, top_offset: -80,
        z_layer: 25
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.8))
    ]
  )

  # Yellow - bottom right
  Engine::GameObject.create(
    name: "BottomRight",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 1.0, left_offset: -80,
        right_offset: 10,
        bottom_offset: 10,
        top_ratio: 1.0, top_offset: -80,
        z_layer: 25
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.8, 0.8, 0.2))
    ]
  )
end
