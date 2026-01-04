require_relative "../../lib/ruby_rpg"
require "pry"

Engine.start do
  include Asteroids

  Rendering::RenderPipeline.set_skybox_colors(
    ground: Vector[0, 0, 0],
    horizon: Vector[0, 0, 0],
    sky: Vector[0, 0, 0]
  )
  Ship.create(Vector[Engine::Window.width / 2, Engine::Window.height / 2, 0], 20)
  OnscreenUI.create

  Engine::GameObject.create(
    name: "Camera",
    pos: Vector[Engine::Window.framebuffer_width / 2, Engine::Window.framebuffer_height / 2, 0],
    components: [
      Engine::Components::OrthographicCamera.create(
        width: Engine::Window.framebuffer_width, height: Engine::Window.framebuffer_height, far: 1000
      )
    ]
  )

  10.times do
    Asteroid.create(
      Vector[rand(Engine::Window.framebuffer_width), rand(Engine::Window.framebuffer_height), 0],
      rand(360),
      rand(50..100)
    )
  end
end
