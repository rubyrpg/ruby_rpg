# frozen_string_literal: true

def create_left_sidebar(font)
  left_sidebar = Engine::GameObject.create(
    name: "LeftSidebar",
    components: [
      Engine::Components::UI::Rect.create(
        right_ratio: 1.0,
        right_offset: -200,
        top_offset: 50,
        bottom_offset: 50
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.3, 0.3, 0.3))
    ]
  )

  # Flex column of menu items
  menu_column = Engine::GameObject.create(
    name: "MenuColumn",
    parent: left_sidebar,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_offset: 10,
        top_offset: 10,
        bottom_offset: 10
      ),
      Engine::Components::UI::Flex.create(direction: :column, gap: 5)
    ]
  )

  5.times do |i|
    Engine::GameObject.create(
      name: "MenuItem#{i}",
      parent: menu_column,
      components: [
        Engine::Components::UI::Rect.create,
        Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.5, 0.6, 0.7))
      ]
    )
  end

  # Sidebar title
  Engine::GameObject.create(
    name: "SidebarTitle",
    components: [
      Engine::Components::UI::Rect.create(
        right_ratio: 1.0, right_offset: -200,
        top_offset: 60,
        bottom_ratio: 1.0, bottom_offset: -90
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Menu")
    ]
  )

  left_sidebar
end
