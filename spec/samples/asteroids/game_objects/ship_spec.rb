# frozen_string_literal: true

require_relative "../../../../samples/asteroids/game_objects/ship"

include TestDriver

describe Asteroids::Ship do
  before do
    stub_const("GAME_DIR", File.expand_path(File.join(__dir__, "..", "..", "..", "..", "samples", "asteroids")))
  end

  describe "When placed in the scene" do
    it "renders the ship" do
      within_game_context(load_path: "./samples/asteroids") do
        at(0) do
          Asteroids::Ship.create(Vector[100, 100], 90)
          Engine::GameObject.create(
            name: "Camera",
            pos: Vector[800/2, 600/2, 0],
            components: [
              Engine::Components::OrthographicCamera.create(
                width: 800, height: 600, far: 1000
              )
            ]
          )
        end
        at(1) { check_screenshot(__dir__ + "/ship_1.png") }
        at(2) { check_screenshot(__dir__ + "/ship_2.png") }
        till(5) { press(GLFW::KEY_LEFT) }
        at(6) { check_screenshot(__dir__ + "/ship_3.png") }
        till(10) { press(GLFW::KEY_RIGHT) }
        at(11) { check_screenshot(__dir__ + "/ship_4.png") }
        till(15) { press(GLFW::KEY_UP) }
        at(16) { check_screenshot(__dir__ + "/ship_5.png") }
        at(20) do
          check_screenshot(__dir__ + "/ship_6.png")
          Engine.stop_game
        end
      end
    end
  end
end
