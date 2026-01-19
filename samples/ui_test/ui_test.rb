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
end
