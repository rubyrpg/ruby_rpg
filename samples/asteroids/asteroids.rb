require_relative "../../lib/ruby_rpg"
require "pry"

ASSETS_DIR = File.expand_path(File.join(__dir__, "assets"))

Engine.start do
  include Asteroids
  Ship.create(Vector[Engine::Window.width / 2, Engine::Window.height / 2, 0], 20)
  OnscreenUI.create

  Engine::GameObject.new(
    "Camera",
    pos: Vector[Engine::Window.framebuffer_width / 2, Engine::Window.framebuffer_height / 2, 0],
    components: [
      Engine::Components::OrthographicCamera.new(
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
