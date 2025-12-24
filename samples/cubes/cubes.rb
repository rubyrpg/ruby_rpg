require_relative "../../lib/ruby_rpg"
require_relative "components/spotlight_controller"

Engine.start do
  include Cubes

  # Rendering::PostProcessingEffect.add(
  #   Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0)
  # )

  Engine::GameObject.new(
    "Camera",
    pos: Vector[0, 50, 70],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  sphere = Sphere.create(Vector[0, 20, 0], 0, 5)
  Cube.create(Vector[25, 20, -30], Vector[60, 0, 0], 8)

  # Directional light (sun-like)
  Engine::GameObject.new(
    "DirectionalLight",
    pos: Vector[0, 50, 0],
    rotation: Vector[-30, 190, 0],
    components: [
      Engine::Components::DirectionLight.new(colour: Vector[0.5, 1, 1], cast_shadows: true)
    ]
  )

  # Point light (dimmed)
  Engine::GameObject.new(
    "PointLight",
    pos: Vector[-20, 35, 10],
    components: [
      Engine::Components::PointLight.new(range: 150, colour: Vector[0.15, 0.05, 0.05], cast_shadows: true)
    ]
  )

  # Spot light
  Engine::GameObject.new(
    "SpotLight",
    pos: Vector[-30, 40, 20],
    rotation: Vector[-180, -20, 0],
    components: [
      Engine::Components::SpotLight.new(range: 120, colour: Vector[0.1, 3, 0.3], inner_angle: 15, outer_angle: 25, cast_shadows: true)
    ]
  )

  # Sphere.create(spotlight_pos, 0, 2)  # temporarily disabled for shadow debug

  # Floor planes (3x3 grid)
  chessboard = Engine::Texture.for("assets/chessboard.png").texture
  brick_normal = Engine::Texture.for("assets/brick_normal.png").texture
  tile_size = 50
  (-1..1).each do |x|
    (-1..1).each do |z|
      Plane.create(Vector[x * tile_size, 0, z * tile_size], Vector[90, 0, 0], tile_size, chessboard, brick_normal)
    end
  end

  # Back wall
  Plane.create(Vector[0, 25, -50], Vector[0, 0, 0], 50, chessboard, brick_normal)

  # World-space text (follows camera perspective)
  Text.create(Vector[0, 35, 0], Vector[0, 0, 0], 5, "Hello World")

  # UI text (screen-space, fixed position)
  UIText.create(Vector[50, 50, 0], Vector[0, 0, 0], 30, "UI Text")
end
