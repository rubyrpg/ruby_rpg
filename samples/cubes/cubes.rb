require_relative "../../lib/ruby_rpg"

Engine.start do
  include Cubes
  (-3..3).each do |x|
    Plane.create(Vector[x * 100, 100, -100], Vector[0, 0, 0], 100)
    (0..3).each do |y|
      Plane.create(Vector[x * 100, 0, y * 100], Vector[90, 0, 0], 100)
    end
  end
  #
  # Sphere.create(Vector[7, 20, 0], 0, 5, [
  #   Engine::Physics::Components::SphereCollider.new(5),
  #   # Spinner.new(90),
  #   Engine::Physics::Components::Rigidbody.new(
  #     mass: 0.5,
  #     velocity: Vector[0, 0, 0],
  #     angular_velocity: Vector[20, 45, 30] * 100,
  #     gravity: Vector[0, 0, 0],
  #     coefficient_of_restitution: 0.95,
  #     coefficient_of_friction: 1
  #   )
  # ]).tap { |sphere| sphere.name = "small" }

  # Sphere.create(Vector[0, 80, 0], 0, 10, [
  #   Engine::Physics::Components::SphereCollider.new(10),
  #   Engine::Physics::Components::Rigidbody.new(
  #     velocity: Vector[0, 0, 0],
  #     gravity: Vector[0, -10, 0],
  #     coefficient_of_friction: 0.1,
  #   )
  # ]).tap { |sphere| sphere.name = "big" }

  # Sphere.create(Vector[0, 0, 0], 0, 10, [
  #   Engine::Physics::Components::SphereCollider.new(10),
  # ])

  # Cube.create(Vector[0, 20, 0], 0, 10)
  # Cube.create_bumped(Vector[50, 20, 0], 0, 10)
  # Teapot.create(Vector[100, 20, 0], 0, 20)
  # Sphere.create_cluster(Vector[200, 50, 0], 0, 10)
  #
  # Cubes::Light.create(Vector[250, 50, 0], 50, Vector[0, 0, 1])
  # Cubes::Light.create(Vector[150, 60, 20], 50, Vector[1, 0, 1])
  # Cubes::Light.create(Vector[200, 100, 50], 50, Vector[0, 1, 0])

  Engine::GameObject.new(
    "Camera",
    pos: Vector[0, 50, 70],
    rotation: Vector[20, 0, 0],
    components: [
      Cubes::CameraRotator.new,
      Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: 1920.0 / 1080.0, near: 0.1, far: 1000.0)
    # Engine::Components::OrthographicCamera.new(width: 1920, height: 1080, far: 1000)
    ])

  Engine::GameObject.new(
    "Direction Light",
    rotation: Vector[-60, 180, 30],
    components: [
      Engine::Components::DirectionLight.new(
        colour: Vector[1.4, 1.4, 1.2],
      )
    ])

  Text.create(Vector[500, 500, 0], Vector[0, 0, 0], 100, "Hello World\nNew Line")

  ui_material = Engine::Material.new(Engine::Shader.ui_sprite)
  ui_material.set_texture("image", Engine::Texture.for("assets/cube.png").texture)
  ui_material.set_vec4("spriteColor", Vector[1, 1, 1, 1])

  Engine::GameObject.new(
    "UI image",
    pos: Vector[100, 100, 0], rotation: Vector[0, 0, 0], scale: Vector[1, 1, 1],
    components: [
      Engine::Components::UISpriteRenderer.new(
        Vector[100, 100], Vector[200, 100], Vector[200, 0], Vector[100, 0],
        ui_material
      )
    ])
  clip = NativeAudio::Clip.new("samples/cubes/assets/boom.wav")
  sound_source = Engine::Components::AudioSource.new(clip)
  pos = Vector[0, 20, 0]
  sound_obj = Engine::GameObject.new(
    "Sound", pos: pos,
    components: [sound_source]
  )
  sound_source.play
  Sphere.create(Vector[0, 20, 0], 0, 10)
end
