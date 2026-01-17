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
        bottom_offset: -50  # expand downward
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
        right_offset: -200,  # expand rightward
        top_offset: 50,      # shrink down from top
        bottom_offset: 50    # shrink up from bottom
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
        right_offset: 20,
        bottom_offset: 20,
        top_offset: 20
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.5, 0.7))
    ]
  )

  # Corner boxes - small 80x80 boxes in each corner (10px from edges)
  # Red - top left
  Engine::GameObject.create(
    name: "TopLeft",
    components: [
      Engine::Components::UIRect.create(
        left_offset: 10,
        right_ratio: 1.0, right_offset: -80,
        bottom_ratio: 1.0, bottom_offset: -80,
        top_offset: 10
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.8, 0.2, 0.2))
    ]
  )

  # Green - top right
  Engine::GameObject.create(
    name: "TopRight",
    components: [
      Engine::Components::UIRect.create(
        left_ratio: 1.0, left_offset: -80,
        right_offset: 10,
        bottom_ratio: 1.0, bottom_offset: -80,
        top_offset: 10
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.8, 0.2))
    ]
  )

  # Blue - bottom left
  Engine::GameObject.create(
    name: "BottomLeft",
    components: [
      Engine::Components::UIRect.create(
        left_offset: 10,
        right_ratio: 1.0, right_offset: -80,
        bottom_offset: 10,
        top_ratio: 1.0, top_offset: -80
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.2, 0.2, 0.8))
    ]
  )

  # Yellow - bottom right
  Engine::GameObject.create(
    name: "BottomRight",
    components: [
      Engine::Components::UIRect.create(
        left_ratio: 1.0, left_offset: -80,
        right_offset: 10,
        bottom_offset: 10,
        top_ratio: 1.0, top_offset: -80
      ),
      Engine::Components::UISpriteRenderer.create(material: create_ui_material(0.8, 0.8, 0.2))
    ]
  )
end
