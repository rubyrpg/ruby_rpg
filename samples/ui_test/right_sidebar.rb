# frozen_string_literal: true

def create_right_sidebar(font)
  right_sidebar = Engine::GameObject.create(
    name: "RightSidebar",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 1.0,
        left_offset: -200,
        top_offset: 50,
        bottom_offset: 50
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.25, 0.25, 0.3))
    ]
  )

  # Title
  Engine::GameObject.create(
    name: "RightSidebarTitle",
    parent: right_sidebar,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: 10,
        bottom_ratio: 1.0, bottom_offset: -40
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Justify Modes")
    ]
  )

  create_justify_example(right_sidebar, font, "StartRow", 50, :start, [0.7, 0.4, 0.4])
  create_justify_example(right_sidebar, font, "CenterRow", 125, :center, [0.4, 0.7, 0.4])
  create_justify_example(right_sidebar, font, "EndRow", 200, :end, [0.4, 0.4, 0.7])
  create_stretch_example(right_sidebar, font, 275)
  create_weighted_example(right_sidebar, font, 350)
  create_mixed_example(right_sidebar, font, 425)

  right_sidebar
end

def create_justify_example(parent, font, name, top_offset, justify, color)
  # Label
  Engine::GameObject.create(
    name: "#{name}Label",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 18)
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: ":#{justify}")
    ]
  )

  # Row - taller to show cross-axis sizing
  row = Engine::GameObject.create(
    name: name,
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 70)
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15)),
      Engine::Components::UI::Flex.create(direction: :row, justify: justify, gap: 5)
    ]
  )

  # Different flex_heights and alignments to demo cross-axis sizing
  items = [
    {width: 40, height: 20, align: :start},
    {width: 60, height: 35, align: :center},
    {width: 30, height: 25, align: :end}
  ]
  items.each_with_index do |dims, i|
    Engine::GameObject.create(
      name: "#{name}Btn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create(flex_width: dims[:width], flex_height: dims[:height], flex_align: dims[:align]),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(*color))
      ]
    )
  end
end

def create_stretch_example(parent, font, top_offset)
  # Label
  Engine::GameObject.create(
    name: "StretchLabel",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 18)
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: ":stretch")
    ]
  )

  # Row - taller to show cross-axis sizing
  row = Engine::GameObject.create(
    name: "StretchRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 70)
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15)),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  # Different flex_heights with alignments
  items = [
    {height: 25, align: :start},
    {height: nil, align: nil},  # stretches
    {height: 40, align: :end}
  ]
  items.each_with_index do |dims, i|
    Engine::GameObject.create(
      name: "StretchBtn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create(flex_height: dims[:height], flex_align: dims[:align]),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.7, 0.7, 0.4))
      ]
    )
  end
end

def create_weighted_example(parent, font, top_offset)
  # Label
  Engine::GameObject.create(
    name: "WeightedLabel",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 18)
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "weight 1:2:1")
    ]
  )

  # Row - taller to show cross-axis sizing
  row = Engine::GameObject.create(
    name: "WeightedRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 70)
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15)),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  # weight 1, weight 2, weight 1 - with different heights
  [{weight: 1, height: 20}, {weight: 2, height: nil}, {weight: 1, height: 35}].each_with_index do |dims, i|
    Engine::GameObject.create(
      name: "WeightedBtn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create(flex_weight: dims[:weight], flex_height: dims[:height]),
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.6, 0.4, 0.7))
      ]
    )
  end
end

def create_mixed_example(parent, font, top_offset)
  # Label
  Engine::GameObject.create(
    name: "MixedLabel",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 18)
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "fixed+weight")
    ]
  )

  # Row - taller to show cross-axis sizing
  row = Engine::GameObject.create(
    name: "MixedRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 70)
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.15, 0.15, 0.15)),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  # Fixed 30px with fixed height
  Engine::GameObject.create(
    name: "MixedFixed",
    parent: row,
    components: [
      Engine::Components::UI::Rect.create(flex_width: 30, flex_height: 30),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.7, 0.5, 0.3))
    ]
  )

  # Weighted (takes remaining space, stretches height)
  Engine::GameObject.create(
    name: "MixedWeighted",
    parent: row,
    components: [
      Engine::Components::UI::Rect.create(flex_weight: 1),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.4, 0.6, 0.5))
    ]
  )
end
