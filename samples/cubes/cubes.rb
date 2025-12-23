require_relative "../../lib/ruby_rpg"

Engine.start do
  include Cubes

  Rendering::PostProcessingEffect.add(
    Rendering::PostProcessingEffect.bloom(threshold: 0.8, intensity: 1.0, blur_passes: 3, blur_scale: 5.0)
  )

  Engine::GameObject.new(
    "Camera",
    pos: Vector[0, 50, 70],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    ])

  Engine::GameObject.new(
    "Direction Light",
    rotation: Vector[-60, 180, 30],
    components: [
      Engine::Components::DirectionLight.new(
        colour: Vector[0.5, 0.5, 0.5],
      )
    ])

  sphere = Sphere.create(Vector[0, 20, 0], 0, 5)
  Cube.create(Vector[25, 20, 0], Vector[0, 0, 0], 8)

  Engine::GameObject.new(
    "Purple Light",
    pos: Vector[0, 20, 0],
    components: [
      Engine::Components::PointLight.new(range: 50, colour: Vector[1.0, 0.0, 1.0])
    ]
  )

  # Floor planes (3x3 grid)
  chessboard = Engine::Texture.for("assets/chessboard.png").texture
  tile_size = 50
  (-1..1).each do |x|
    (-1..1).each do |z|
      Plane.create(Vector[x * tile_size, 0, z * tile_size], Vector[90, 0, 0], tile_size, chessboard)
    end
  end

  # Back wall
  Plane.create(Vector[0, 25, -50], Vector[0, 0, 0], 50, Engine::Texture.for("assets/chessboard.png").texture)

  # World-space text (follows camera perspective)
  Text.create(Vector[0, 35, 0], Vector[0, 0, 0], 5, "Hello World")

  # UI text (screen-space, fixed position)
  UIText.create(Vector[50, 50, 0], Vector[0, 0, 0], 30, "UI Text")
end
