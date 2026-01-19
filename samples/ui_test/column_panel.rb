# frozen_string_literal: true

def create_column_panel(font)
  # Position: left of right sidebar, wider to show cross-axis sizing
  panel = Engine::GameObject.create(
    name: "ColumnPanel",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 1.0,
        left_offset: -460,
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

  # Column flex container with background to show cross-axis sizing
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
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.1, 0.1, 0.1)),
      Engine::Components::UI::Flex.create(direction: :column, justify: justify, gap: 2)
    ]
  )

  # Different widths and alignments to demo cross-axis sizing
  items = [
    {height: 50, width: 30, align: :start},
    {height: 20, width: 40, align: :center},
    {height: 90, width: 35, align: :end}
  ]
  items.each_with_index do |dims, i|
    Engine::GameObject.create(
      name: "Col#{label}Item#{i}",
      parent: column,
      components: [
        Engine::Components::UI::Rect.create(flex_height: dims[:height], flex_width: dims[:width], flex_align: dims[:align]),
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

  # Column flex container with background to show cross-axis sizing
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
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.1, 0.1, 0.1)),
      Engine::Components::UI::Flex.create(direction: :column, justify: :stretch, gap: 2)
    ]
  )

  # Weights 1:2:1 with different widths and alignments
  items = [
    {weight: 1, width: 25, align: :start},
    {weight: 2, width: nil, align: nil},  # stretches
    {weight: 1, width: 40, align: :end}
  ]
  items.each_with_index do |dims, i|
    Engine::GameObject.create(
      name: "ColStretchItem#{i}",
      parent: column,
      components: [
        Engine::Components::UI::Rect.create(flex_weight: dims[:weight], flex_width: dims[:width], flex_align: dims[:align]),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.7, 0.7, 0.4))
      ]
    )
  end
end
