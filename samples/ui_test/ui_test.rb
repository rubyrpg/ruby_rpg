require_relative "../../lib/ruby_rpg"
require_relative "top_bar"
require_relative "bottom_bar"
require_relative "left_sidebar"
require_relative "right_sidebar"
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
  create_center_panel(font)
  create_corners
end
