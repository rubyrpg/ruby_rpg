require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"

def load_material(name)
  Engine::Serializable.from_file(File.join(GAME_DIR, "assets/#{name}.mat"))
end

Engine.start do
  include Cubes

  # Navy night sky
  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0.02, 0.02, 0.05],
    horizon: Vector[0.05, 0.05, 0.4],
    sky: Vector[0.02, 0.03, 0.3]
  )

  # Post processing effects
  Rendering::PostProcessingEffect.add_all([
    Rendering::PostProcessingEffect.ssao(kernel_size: 16, radius: 5.0, bias: 0.025, power: 4.0),
    Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 256.0, thickness: 5.0),
    # Rendering::PostProcessingEffect.tint(color: [1.0, 0.0, 0.0], intensity: 0.2),
    Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0),
    # Rendering::PostProcessingEffect.depth_of_field(focus_distance: 70.0, focus_range: 50.0, blur_amount: 2.0),
  ])

  Engine::GameObject.new(
    "Camera",
    pos: Vector[0, 50, 0],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  sphere = Engine::StandardObjects::Sphere.create(
    pos: Vector[0, 20, 0],
    scale: Vector[10, 10, 10],
    material: load_material("hdr_sphere")
  )
  Engine::StandardObjects::Cube.create(pos: Vector[25, 20, -30], scale: Vector[16, 16, 16])

  # Wall of colourful cubes
  cube_materials = [
    load_material("cube_red"),
    load_material("cube_green"),
    load_material("cube_blue"),
    load_material("cube_yellow"),
    load_material("cube_magenta"),
    load_material("cube_cyan"),
    load_material("cube_orange"),
    load_material("cube_purple"),
  ]
  cube_size = 4
  spacing = cube_size * 2 + 1  # cubes are 2 units, scaled, plus gap
  wall_width = 5
  wall_height = 4
  start_pos = Vector[-40, 5, -30]

  wall_width.times do |x|
    wall_height.times do |y|
      material = cube_materials[(x + y) % cube_materials.length]
      pos = start_pos + Vector[x * spacing, y * spacing, 0]
      Engine::StandardObjects::Cube.create(pos: pos, scale: Vector[cube_size * 2, cube_size * 2, cube_size * 2], material: material)
    end
  end

  # # Single white directional light for testing SSR
  Engine::GameObject.new(
    "DirectionalLight",
    pos: Vector[0, 50, 0],
    rotation: Vector[-70, 190, 0],
    components: [
      Engine::Components::DirectionLight.new(colour: Vector[1,1,1], cast_shadows: true, shadow_distance: 150.0)
    ]
  )

  # Point light (dimmed)
  # Engine::GameObject.new(
  #   "PointLight",
  #   pos: Vector[-20, 70, -10],
  #   components: [
  #     Engine::Components::PointLight.new(range: 150, colour: Vector[0.1, 0.1, 0.1], cast_shadows: true),
  #     SpotlightController.new
  #   ]
  # )
  #
  # # Spot light
  # Engine::GameObject.new(
  #   "SpotLight",
  #   pos: Vector[-30, 40, 20],
  #   rotation: Vector[-180, -20, 0],
  #   components: [
  #     Engine::Components::DirectionLight.new(colour: Vector[1, 1, 1], cast_shadows: true)
  #   ]
  # )

  # Sphere.create(spotlight_pos, 0, 2)  # temporarily disabled for shadow debug

  # Floor planes (3x3 grid) - shiny for SSR
  tile_size = 50

  Engine::StandardObjects::Plane.create(
    pos: Vector[-0.2*tile_size, 0, -0.5*tile_size],
    rotation: Vector[90, 0, 0],
    scale: Vector[tile_size * 2, tile_size * 2, tile_size * 2],
    material: load_material("floor")
  )


  # Back wall (disabled for testing)
  # Plane.create(Vector[0, 25, -50], Vector[0, 0, 0], 50, chessboard, brick_normal)

  # World-space text (follows camera perspective)
  Text.create(Vector[0, 35, 0], Vector[0, 0, 0], 5, "Hello World")

  # UI text (screen-space, fixed position)
  UIText.create(Vector[50, 50, 0], Vector[0, 0, 0], 30, "UI Text")
end
