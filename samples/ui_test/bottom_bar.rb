# frozen_string_literal: true

def create_bottom_bar(font)
  bottom_bar = Engine::GameObject.create(
    name: "BottomBar",
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 1.0,
        top_offset: -50,
        z_layer: 20
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  # Flex row of buttons
  button_row = Engine::GameObject.create(
    name: "ButtonRow",
    parent: bottom_bar,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 220,
        right_offset: 100,
        top_offset: 5,
        bottom_offset: 5
      ),
      Engine::Components::UI::Flex.create(direction: :row, gap: 10)
    ]
  )

  button_colors = [
    [0.6, 0.2, 0.2],  # red
    [0.2, 0.6, 0.2],  # green
    [0.2, 0.2, 0.6],  # blue
    [0.6, 0.6, 0.2]   # yellow
  ]

  button_colors.each_with_index do |color, i|
    Engine::GameObject.create(
      name: "Button#{i}",
      parent: button_row,
      components: [
        Engine::Components::UI::Rect.create,
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(*color))
      ]
    )
  end

  # Status label
  Engine::GameObject.create(
    name: "BottomBarLabel",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 220,
        right_ratio: 0.5,
        top_ratio: 1.0, top_offset: -40,
        bottom_offset: 10
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Status: Ready")
    ]
  )

  bottom_bar
end
