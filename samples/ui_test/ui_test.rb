require_relative "../../lib/ruby_rpg"

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
  Engine::GameObject.create(
    name: "TopBar",
    components: [
      Engine::Components::UIRect.create(
        bottom_ratio: 1.0,
        bottom_offset: -50
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  # Bottom bar - full width, 50px tall at bottom
  Engine::GameObject.create(
    name: "BottomBar",
    components: [
      Engine::Components::UIRect.create(
        top_ratio: 1.0,
        top_offset: -50
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.2))
    ]
  )

  # Left sidebar - 200px wide, between top and bottom bars
  Engine::GameObject.create(
    name: "LeftSidebar",
    components: [
      Engine::Components::UIRect.create(
        right_ratio: 1.0,
        right_offset: -200,
        top_offset: -50,
        bottom_offset: 50
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.3, 0.3, 0.3))
    ]
  )

  # Center panel - centered, 50% width, 50% height
  center_panel = Engine::GameObject.create(
    name: "CenterPanel",
    components: [
      Engine::Components::UIRect.create(
        left_ratio: 0.25,
        right_ratio: 0.25,
        bottom_ratio: 0.25,
        top_ratio: 0.25
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.1, 0.3, 0.5, 0.9))
    ]
  )

  # Nested box inside center panel with 20px margin
  Engine::GameObject.create(
    name: "CenterPanelInner",
    parent: center_panel,
    components: [
      Engine::Components::UIRect.create(
        left_offset: 20,
        right_offset: -20,
        bottom_offset: 20,
        top_offset: -20
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.5, 0.7))
    ]
  )

  # Corner boxes - small 80x80 boxes in each corner
  corners = [
    { name: "TopLeft", left: 0, right: 1.0, bottom: 1.0, top: 0, l_off: 10, r_off: -80, b_off: -80, t_off: -10 },
    { name: "TopRight", left: 1.0, right: 0, bottom: 1.0, top: 0, l_off: -80, r_off: -10, b_off: -80, t_off: -10 },
    { name: "BottomLeft", left: 0, right: 1.0, bottom: 0, top: 1.0, l_off: 10, r_off: -80, b_off: 10, t_off: -80 },
    { name: "BottomRight", left: 1.0, right: 0, bottom: 0, top: 1.0, l_off: -80, r_off: -10, b_off: 10, t_off: -80 }
  ]

  colors = [
    [0.8, 0.2, 0.2],  # red
    [0.2, 0.8, 0.2],  # green
    [0.2, 0.2, 0.8],  # blue
    [0.8, 0.8, 0.2]   # yellow
  ]

  corners.each_with_index do |corner, i|
    Engine::GameObject.create(
      name: corner[:name],
      components: [
        Engine::Components::UIRect.create(
          left_ratio: corner[:left],
          right_ratio: corner[:right],
          bottom_ratio: corner[:bottom],
          top_ratio: corner[:top],
          left_offset: corner[:l_off],
          right_offset: corner[:r_off],
          bottom_offset: corner[:b_off],
          top_offset: corner[:t_off]
        ),
        Engine::Components::UISpriteRenderer.create(material: create_ui_material(*colors[i]))
      ]
    )
  end
end
