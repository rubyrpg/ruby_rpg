# frozen_string_literal: true

require_relative "../../../../samples/cubes/game_objects/teapot"

include TestDriver

describe Cubes::Teapot do
  before do
    stub_const("GAME_DIR", File.expand_path(File.join(__dir__, "..", "..", "..", "..", "samples", "cubes")))
  end

  describe "with an orthographic camera" do
    it "renders the teapot" do
      within_game_context(load_path: "./samples/cubes") do
        at(0) do
          Engine::GameObject.create(
            name: "Camera", pos: Vector[Engine::Window.framebuffer_width / 2, Engine::Window.framebuffer_height / 2, 1000],
            components: [
              Engine::Components::OrthographicCamera.create(width: Engine::Window.framebuffer_width, height: Engine::Window.framebuffer_height, far: 2000)
            ]
          )
          Cubes::Teapot.create(Vector[500, 500], Vector[43, 68, 38], 500)
          Engine::GameObject.create(
            name: "light", pos: Vector[1200, 1200, 100], components: [
            Engine::Components::PointLight.new(range: 1000, colour: Vector[0.6, 0.6, 0.6])
          ])
        end
        at(1) { check_screenshot(__dir__ + "/teapot_orthographic.png") }
        at(20) { Engine.stop_game }
      end
    end
  end

  describe "with a perspective camera" do
    it "renders the teapot" do
      within_game_context(load_path: "./samples/cubes") do
        at(0) do
          Cubes::Teapot.create(Vector[500, 500], Vector[43, 68, 38], 500)
          Engine::GameObject.create(
            name: "light", pos: Vector[Engine::Window.framebuffer_width / 2, 500, 100], components: [
            Engine::Components::PointLight.new(
              range: 300,
              colour: Vector[0.5, 0.5, 0.5],
            )
          ])
          Engine::GameObject.create(
            name: "Camera", pos: Vector[Engine::Window.framebuffer_width / 2, Engine::Window.framebuffer_height / 2, 1000],
            components: [
              Engine::Components::PerspectiveCamera.new(fov: 45.0, aspect: Engine::Window.framebuffer_width / Engine::Window.framebuffer_height, near: 0.1, far: 2000)
            ]
          )
        end
        at(1) { check_screenshot(__dir__ + "/teapot_perspective.png") }
        at(20) { Engine.stop_game }
      end
    end
  end
end
