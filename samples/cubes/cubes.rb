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

  if OS.mac?
    # Use Metal compute shaders on Mac (OpenGL 4.1 doesn't support compute)
    color_texture = Engine::Metal::SharedTexture.new(512, 512)
    normal_texture = Engine::Metal::SharedTexture.new(512, 512)

    compute_shader = Engine::Metal::ComputeShader.new("assets/hello_cubes.metal")
    Plane.create(Vector[0, 0, 0], Vector[90, 0, 0], 50, color_texture.gl_texture, normal_texture.gl_texture)

    Engine::GameObject.new(
      "Metal Compute Animator",
      components: [
        MetalComputeShaderAnimator.new(compute_shader, [color_texture, normal_texture])
      ])
  else
    # Use OpenGL compute shaders on Windows/Linux
    def create_compute_texture(width, height)
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      texture = tex_buf.unpack('L')[0]
      GL.BindTexture(GL::TEXTURE_2D, texture)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA32F, width, height, 0, GL::RGBA, GL::FLOAT, nil)
      texture
    end

    color_texture = create_compute_texture(512, 512)
    normal_texture = create_compute_texture(512, 512)

    compute_shader = Engine::ComputeShader.new("assets/hello_cubes.comp")
    Plane.create(Vector[0, 0, 0], Vector[-90, 0, 0], 50, color_texture, normal_texture)

    Engine::GameObject.new(
      "Compute Animator",
      components: [
        ComputeShaderAnimator.new(compute_shader, [color_texture, normal_texture])
      ])
  end

  Sphere.create(Vector[0, 20, 0], 0, 10)
end
