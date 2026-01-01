require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"

def coloured_material(colour)
  material = Engine::Material.new(Engine::Shader.default)
  material.set_vec3("baseColour", colour)
  material.set_texture("image", nil)
  material.set_texture("normalMap", nil)
  material.set_float("diffuseStrength", 0.5)
  material.set_float("specularStrength", 0.7)
  material.set_float("specularPower", 32.0)
  material.set_vec3("ambientLight", Vector[0.02, 0.02, 0.02])
  material.set_float("roughness", 0.7)
  material
end

def floor_material(texture, normal, roughness)
  material = Engine::Material.new(Engine::Shader.default)
  material.set_texture("image", texture)
  material.set_texture("normalMap", normal)
  material.set_float("diffuseStrength", 0.5)
  material.set_float("specularStrength", 0.7)
  material.set_float("specularPower", 32.0)
  material.set_vec3("ambientLight", Vector[0.02, 0.02, 0.02])
  material.set_float("roughness", roughness)
  material.set_vec3("baseColour", Vector[1.0, 1.0, 1.0])
  material
end

Engine.start do
  include Cubes

  # Screen-space reflections
  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.ssr(max_steps: 128, max_ray_distance: 256.0, thickness: 5.0)
  )

  # Tint for testing
  # Rendering::PostProcessingEffect.add(
  #   Rendering::PostProcessingEffect.tint(color: [1.0, 0.0, 0.0], intensity: 0.2)
  # )

  # Rendering::PostProcessingEffect.add(
  #   Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0)
  # )
  #
  # Rendering::PostProcessingEffect.add(
  #   Rendering::PostProcessingEffect.depth_of_field(focus_distance: 70.0, focus_range: 50.0, blur_amount: 2.0)
  # )

  Engine::GameObject.new(
    "Camera",
    pos: Vector[0, 50, 0],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  sphere = Engine::StandardObjects::Sphere.create(pos: Vector[0, 20, 0], scale: Vector[10, 10, 10])
  Engine::StandardObjects::Cube.create(pos: Vector[25, 20, -30], scale: Vector[16, 16, 16])

  # Wall of colourful cubes
  colours = [
    Vector[1.0, 0.2, 0.2],  # Red
    Vector[0.2, 1.0, 0.2],  # Green
    Vector[0.2, 0.2, 1.0],  # Blue
    Vector[1.0, 1.0, 0.2],  # Yellow
    Vector[1.0, 0.2, 1.0],  # Magenta
    Vector[0.2, 1.0, 1.0],  # Cyan
    Vector[1.0, 0.6, 0.2],  # Orange
    Vector[0.6, 0.2, 1.0],  # Purple
  ]
  cube_size = 4
  spacing = cube_size * 2 + 1  # cubes are 2 units, scaled, plus gap
  wall_width = 5
  wall_height = 4
  start_pos = Vector[-40, 5, -30]

  wall_width.times do |x|
    wall_height.times do |y|
      colour = colours[(x + y) % colours.length]
      pos = start_pos + Vector[x * spacing, y * spacing, 0]
      Engine::StandardObjects::Cube.create(pos: pos, scale: Vector[cube_size * 2, cube_size * 2, cube_size * 2], material: coloured_material(colour))
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
  chessboard = Engine::Texture.for("assets/chessboard.png").texture
  brick_normal = Engine::Texture.for("assets/brick_normal.png").texture
  tile_size = 50

  Engine::StandardObjects::Plane.create(
    pos: Vector[-0.2*tile_size, 0, -0.5*tile_size],
    rotation: Vector[90, 0, 0],
    scale: Vector[tile_size * 2, tile_size * 2, tile_size * 2],
    material: floor_material(nil, nil, 0.1)
  )


  # Back wall (disabled for testing)
  # Plane.create(Vector[0, 25, -50], Vector[0, 0, 0], 50, chessboard, brick_normal)

  # World-space text (follows camera perspective)
  Text.create(Vector[0, 35, 0], Vector[0, 0, 0], 5, "Hello World")

  # UI text (screen-space, fixed position)
  UIText.create(Vector[50, 50, 0], Vector[0, 0, 0], 30, "UI Text")
end
