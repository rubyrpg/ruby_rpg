require_relative "../../lib/ruby_rpg"

def load_font
  Engine::Font.create(font_file_path: "assets/Arial.ttf")
end

def create_ui_material(r, g, b, a = 1.0)
  mat = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  mat.set_vec4("spriteColor", [r, g, b, a])
  mat.set_runtime_texture("image", Engine::Material.default_white_texture)
  mat
end

Engine.start do
  # Black sky
  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0, 0, 0],
    horizon: Vector[0, 0, 0],
    sky: Vector[0, 0, 0]
  )

  # Camera (needed for rendering)
  Engine::GameObject.create(
    name: "Camera",
    components: [
      Engine::Components::PerspectiveCamera.create(fov: 45.0, aspect: 16.0 / 9.0, near: 0.1, far: 100.0)
    ]
  )

  # Top bar - full width, 50px tall at top
  top_bar = Engine::GameObject.create(
    name: "TopBar",
    components: [
      Engine::Components::UI::Rect.create(
        bottom_ratio: 1.0,
        bottom_offset: -50  # expand downward
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  # Text label in top bar
  Engine::GameObject.create(
    name: "TopBarLabel",
    parent: top_bar,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_ratio: 0.5,
        top_offset: 5,
        bottom_offset: 5
      ),
      Engine::Components::UI::FontRenderer.create(font: load_font, string: "UI Test")
    ]
  )

  # Bottom bar - full width, 50px tall at bottom
  bottom_bar = Engine::GameObject.create(
    name: "BottomBar",
    components: [
      Engine::Components::UI::Rect.create(
        top_ratio: 1.0,
        top_offset: -50
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  # Flex row of buttons in bottom bar
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

  # Create 4 buttons
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

  # Left sidebar - 200px wide, between top and bottom bars
  left_sidebar = Engine::GameObject.create(
    name: "LeftSidebar",
    components: [
      Engine::Components::UI::Rect.create(
        right_ratio: 1.0,
        right_offset: -200,  # expand rightward
        top_offset: 50,      # shrink down from top
        bottom_offset: 50    # shrink up from bottom
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.3, 0.3, 0.3))
    ]
  )

  # Flex column of menu items in sidebar
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

  # Create 5 menu items
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

  # Center panel - centered, 50% width, 50% height
  center_panel = Engine::GameObject.create(
    name: "CenterPanel",
    components: [
      Engine::Components::UI::Rect.create(
        left_ratio: 0.25,
        right_ratio: 0.25,
        bottom_ratio: 0.25,
        top_ratio: 0.25
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.1, 0.3, 0.5, 0.9))
    ]
  )

  # Nested box inside center panel with 20px margin
  Engine::GameObject.create(
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

  # Corner boxes - small 80x80 boxes in each corner (10px from edges)
  # Red - top left
  Engine::GameObject.create(
    name: "TopLeft",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 10,
        right_ratio: 1.0, right_offset: -80,
        bottom_ratio: 1.0, bottom_offset: -80,
        top_offset: 10
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
        top_offset: 10
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
        top_ratio: 1.0, top_offset: -80
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
        top_ratio: 1.0, top_offset: -80
      ),
      Engine::Components::UI::SpriteRenderer.create(material: create_ui_material(0.8, 0.8, 0.2))
    ]
  )

  # Text examples at different sizes inside the center panel
  font = load_font

  # Large title (60px)
  Engine::GameObject.create(
    name: "LargeText",
    parent: center_panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 20,
        right_offset: 20,
        top_offset: 20,
        bottom_ratio: 1.0, bottom_offset: -80
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Large Title")
    ]
  )

  # Medium text (40px)
  Engine::GameObject.create(
    name: "MediumText",
    parent: center_panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 20,
        right_offset: 20,
        top_ratio: 0.5, top_offset: -10,
        bottom_ratio: 0.5, bottom_offset: -30
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Medium text here")
    ]
  )

  # Small text (20px)
  Engine::GameObject.create(
    name: "SmallText",
    parent: center_panel,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 20,
        right_offset: 20,
        top_ratio: 1.0, top_offset: -50,
        bottom_offset: 20
      ),
      Engine::Components::UI::FontRenderer.create(font: font, string: "Small footer text")
    ]
  )

  # Label in left sidebar
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

  # Bottom bar label
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
end
