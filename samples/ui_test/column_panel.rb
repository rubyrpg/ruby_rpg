# frozen_string_literal: true

def create_column_panel(font)
  # Position: left of right sidebar, 150px wide
  panel = Engine::GameObject.create(
    name: "ColumnPanel",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 1.0,
        left_offset: -360,
        right_offset: 210,
        top_ratio: 0,
        top_offset: 60,
        bottom_ratio: 1.0,
        bottom_offset: -460
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.25, 0.2))
    ]
  )

  # Title
  Engine::GameObject.create(
    name: "ColumnPanelTitle",
    parent: panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 5,
        right_offset: 5,
        top_offset: 5,
        bottom_ratio: 1.0,
        bottom_offset: -22
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Column")
    ]
  )

  # Row of column examples
  examples_row = Engine::GameObject.create(
    name: "ColumnExamplesRow",
    parent: panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 5,
        right_offset: 5,
        top_offset: 28,
        bottom_offset: 5
      ),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 3)
    ]
  )

  create_column_example(examples_row, font, "S", :start, [0.7, 0.4, 0.4])
  create_column_example(examples_row, font, "C", :center, [0.4, 0.7, 0.4])
  create_column_example(examples_row, font, "E", :end, [0.4, 0.4, 0.7])
  create_column_stretch_example(examples_row, font)

  panel
end

def create_column_example(parent, font, label, justify, color)
  container = Engine::GameObject.create(
    name: "Col#{label}Container",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create,
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15))
    ]
  )

  # Label at top
  Engine::GameObject.create(
    name: "Col#{label}Label",
    parent: container,
    components: [
      Engine::Components::UI::Rect.create(
        top_offset: 1,
        bottom_ratio: 1.0,
        bottom_offset: -20
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: label)
    ]
  )

  # Column flex container
  column = Engine::GameObject.create(
    name: "Col#{label}Flex",
    parent: container,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 2,
        right_offset: 2,
        top_offset: 22,
        bottom_offset: 2
      ),
      Engine::Components::UI::Flex.create(direction: :column, justify: justify, gap: 2)
    ]
  )

  [50, 20, 90].each_with_index do |height, i|
    Engine::GameObject.create(
      name: "Col#{label}Item#{i}",
      parent: column,
      components: [
        Engine::Components::UI::Rect.create(flex_height: height),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(*color))
      ]
    )
  end
end

def create_column_stretch_example(parent, font)
  container = Engine::GameObject.create(
    name: "ColStretchContainer",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create,
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15))
    ]
  )

  # Label at top
  Engine::GameObject.create(
    name: "ColStretchLabel",
    parent: container,
    components: [
      Engine::Components::UI::Rect.create(
        top_offset: 1,
        bottom_ratio: 1.0,
        bottom_offset: -20
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "=")
    ]
  )

  # Column flex container
  column = Engine::GameObject.create(
    name: "ColStretchFlex",
    parent: container,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 2,
        right_offset: 2,
        top_offset: 22,
        bottom_offset: 2
      ),
      Engine::Components::UI::Flex.create(direction: :column, justify: :stretch, gap: 2)
    ]
  )

  # Weights 1:2:1 to show proportional sizing
  weights = [1, 2, 1]
  weights.each_with_index do |weight, i|
    Engine::GameObject.create(
      name: "ColStretchItem#{i}",
      parent: column,
      components: [
        Engine::Components::UI::Rect.create(flex_weight: weight),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.7, 0.7, 0.4))
      ]
    )
  end
end
