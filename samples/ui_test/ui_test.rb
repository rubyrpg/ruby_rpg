require_relative "../../lib/ruby_rpg"
require_relative "top_bar"
require_relative "bottom_bar"
require_relative "left_sidebar"
require_relative "right_sidebar"
require_relative "column_panel"
require_relative "center_panel"
require_relative "corners"

def load_font
  Engine::Font.create(font_file_path: "assets/Arial.ttf")
end

def create_ui_material(r, g, b, a = 1.0)
  mat = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  mat.set_vec4("spriteColor", [r, g, b, a])
  mat.set_runtime_texture("image", Engine::Material.default_white_texture)
  mat
end

def create_sprite_material(texture_path)
  texture = Engine::Texture.for(texture_path)
  mat = Engine::Material.create(shader: Engine::Shader.ui_sprite)
  mat.set_vec4("spriteColor", [1, 1, 1, 1])
  mat.set_runtime_texture("image", texture.texture)
  mat
end

def create_smiley_sprite
  Engine::GameObject.create(
    name: "SmileySprite",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 50,
        top_offset: 100,
        right_ratio: 1.0,
        right_offset: -170,
        bottom_ratio: 1.0,
        bottom_offset: -220,
        z_layer: 30
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )
end

def create_masked_smiley_demo
  # Small mask container (dark red to show bounds)
  mask_container = Engine::GameObject.create(
    name: "MaskContainer",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 400,
        top_offset: 300,
        right_ratio: 1.0,
        right_offset: -550,
        bottom_ratio: 1.0,
        bottom_offset: -450,
        z_layer: 200,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.3, 0.1, 0.1, 1.0)
      )
    ]
  )

  # Large smiley that extends beyond the mask - should be clipped
  Engine::GameObject.create(
    name: "ClippedSmiley",
    parent: mask_container,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: -50,
        top_offset: -50,
        right_offset: -100,
        bottom_offset: -100
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )
end

def create_sprite_mask_demo
  # Smiley as the mask - should clip children to its alpha shape
  smiley_mask = Engine::GameObject.create(
    name: "SmileyMask",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 250,
        top_offset: 400,
        right_ratio: 1.0,
        right_offset: -400,
        bottom_ratio: 1.0,
        bottom_offset: -550,
        z_layer: 400,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )

  # Solid color child that fills the mask - should be clipped to smiley shape
  Engine::GameObject.create(
    name: "ColorFill",
    parent: smiley_mask,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 0,
        top_offset: 0,
        right_offset: 0,
        bottom_offset: 0
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(1.0, 0.0, 0.5, 1.0)
      )
    ]
  )
end

def create_nested_hierarchy_demo
  # Outer mask container (dark blue)
  outer_mask = Engine::GameObject.create(
    name: "OuterMask",
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 600,
        top_offset: 300,
        right_ratio: 1.0,
        right_offset: -750,
        bottom_ratio: 1.0,
        bottom_offset: -450,
        z_layer: 300,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.1, 0.1, 1, 1.0)
      )
    ]
  )

  # Middle child (green, not a mask, extends beyond parent)
  middle_child = Engine::GameObject.create(
    name: "MiddleChild",
    parent: outer_mask,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: 20,
        top_offset: 20,
        right_offset: -40,
        bottom_offset: -40,
        mask: true
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_ui_material(0.1, 0.3, 0.1, 1.0)
      )
    ]
  )

  # Grandchild smiley (extends beyond middle child, but clipped by outer mask)
  Engine::GameObject.create(
    name: "GrandchildSmiley",
    parent: middle_child,
    components: [
      Engine::Components::UI::Rect.create(
        left_offset: -30,
        top_offset: -30,
        right_offset: -60,
        bottom_offset: -60
      ),
      Engine::Components::UI::SpriteRenderer.create(
        material: create_sprite_material("assets/smiley.png")
      )
    ]
  )
end

Engine.start do
  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0, 0, 0],
    horizon: Vector[0, 0, 0],
    sky: Vector[0, 0, 0]
  )

  Engine::GameObject.create(
    name: "Camera",
    components: [
      Engine::Components::PerspectiveCamera.create(fov: 45.0, aspect: 16.0 / 9.0, near: 0.1, far: 100.0)
    ]
  )

  font = load_font

  create_top_bar(font)
  create_bottom_bar(font)
  create_left_sidebar(font)
  create_right_sidebar(font)
  create_column_panel(font)
  create_center_panel(font)
  create_corners
  create_smiley_sprite
  create_masked_smiley_demo
  create_nested_hierarchy_demo
  create_sprite_mask_demo
end
