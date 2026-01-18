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
  create_justify_example(right_sidebar, font, "CenterRow", 95, :center, [0.4, 0.7, 0.4])
  create_justify_example(right_sidebar, font, "EndRow", 140, :end, [0.4, 0.4, 0.7])
  create_stretch_example(right_sidebar, font, 185)
  create_weighted_example(right_sidebar, font, 230)
  create_mixed_example(right_sidebar, font, 275)

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

  # Row
  row = Engine::GameObject.create(
    name: name,
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 45)
      ),
      Engine::Components::UI::Flex.create(direction: :row, justify: justify, gap: 5)
    ]
  )

  [40, 60, 30].each_with_index do |width, i|
    Engine::GameObject.create(
      name: "#{name}Btn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create(flex_width: width),
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

  # Row
  row = Engine::GameObject.create(
    name: "StretchRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 45)
      ),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  3.times do |i|
    Engine::GameObject.create(
      name: "StretchBtn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create,
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

  # Row
  row = Engine::GameObject.create(
    name: "WeightedRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 45)
      ),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  # weight 1, weight 2, weight 1
  [1, 2, 1].each_with_index do |weight, i|
    Engine::GameObject.create(
      name: "WeightedBtn#{i}",
      parent: row,
      components: [
        Engine::Components::UI::Rect.create(flex_weight: weight),
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

  # Row
  row = Engine::GameObject.create(
    name: "MixedRow",
    parent: parent,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: top_offset + 20,
        bottom_ratio: 1.0, bottom_offset: -(top_offset + 45)
      ),
      Engine::Components::UI::Flex.create(direction: :row, justify: :stretch, gap: 5)
    ]
  )

  # Fixed 30px
  Engine::GameObject.create(
    name: "MixedFixed",
    parent: row,
    components: [
      Engine::Components::UI::Rect.create(flex_width: 30),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.7, 0.5, 0.3))
    ]
  )

  # Weighted (takes remaining space)
  Engine::GameObject.create(
    name: "MixedWeighted",
    parent: row,
    components: [
      Engine::Components::UI::Rect.create(flex_weight: 1),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.4, 0.6, 0.5))
    ]
  )
end
