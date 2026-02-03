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

  # Open Sans
  Engine::GameObject.create(
    name: "OpenSansText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_offset: 0,
        bottom_ratio: 1.0, bottom_offset: -60
      ),
      Engine::Components::UI::FontRenderer.create(font: Engine::Font.open_sans, string: "Open Sans")
    ]
  )

  # Noto Serif
  Engine::GameObject.create(
    name: "NotoSerifText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 0.5, top_offset: -20,
        bottom_ratio: 0.5, bottom_offset: -40
      ),
      Engine::Components::UI::FontRenderer.create(font: Engine::Font.noto_serif, string: "Noto Serif")
    ]
  )

  # JetBrains Mono
  Engine::GameObject.create(
    name: "JetBrainsMonoText",
    parent: inner_panel,
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 1.0, top_offset: -40,
        bottom_offset: 0
      ),
      Engine::Components::UI::FontRenderer.create(font: Engine::Font.jetbrains_mono, string: "JetBrains Mono")
    ]
  )

  center_panel
end
