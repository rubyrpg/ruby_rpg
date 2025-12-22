require_relative "../../lib/ruby_rpg"

Engine.start do
  include Cubes

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
        colour: Vector[1.4, 1.4, 1.2],
      )
    ])

  # Create compute textures and shader (platform-agnostic)
  color_texture = Engine::ComputeTexture.new(512, 512)
  normal_texture = Engine::ComputeTexture.new(512, 512)
  compute_shader = Engine::ComputeShader.new("assets/hello_cubes.comp")

  Plane.create(Vector[0, 0, 0], Vector[90, 0, 0], 50, color_texture.gl_texture, normal_texture.gl_texture)

  Engine::GameObject.new(
    "Compute Animator",
    components: [
      ComputeShaderAnimator.new(compute_shader, [color_texture, normal_texture])
    ])

  Sphere.create(Vector[0, 20, 0], 0, 10)
end
