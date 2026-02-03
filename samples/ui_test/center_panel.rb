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

  # Nested box with 20px margin, using Flex for vertical layout
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
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15)),
      Engine::Components::UI::Flex.create(direction: :column, justify: :start, gap: 5)
    ]
  )

  # Font samples
  fonts = [
    { font: Engine::Font.open_sans, name: "Open Sans" },
    { font: Engine::Font.noto_serif, name: "Noto Serif" },
    { font: Engine::Font.jetbrains_mono, name: "JetBrains Mono" },
    { font: Engine::Font.press_start_2p, name: "Press Start 2P" },
    { font: Engine::Font.bangers, name: "Bangers" },
    { font: Engine::Font.caveat, name: "Caveat" },
    { font: Engine::Font.oswald, name: "Oswald" }
  ]

  fonts.each do |entry|
    Engine::GameObject.create(
      name: "#{entry[:name].gsub(' ', '')}Text",
      parent: inner_panel,
      components: [
        Engine::Components::UI::Rect.create(flex_height: 30),
        Engine::Components::UI::FontRenderer.create(font: entry[:font], string: entry[:name])
      ]
    )
  end

  center_panel
end
