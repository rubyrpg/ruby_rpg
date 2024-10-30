# frozen_string_literal: true

require_relative "../../../../samples/asteroids/game_objects/bullet"

include TestDriver

describe Asteroids::Bullet do
  before do
    stub_const("GAME_DIR", File.expand_path(File.join(__dir__, "..", "..", "..", "..", "samples", "asteroids")))
  end

  describe "When placed in the scene" do
    it "renders the moving bullet" do
      within_game_context(load_path: "./samples/asteroids") do
        at(0) {
          Asteroids::Bullet.create(Vector[100, 100], 45)
          Engine::GameObject.new(
            "Camera",
            pos: Vector[800/2, 600/2, 0],
            components: [
              Engine::Components::OrthographicCamera.new(
                width: 800, height: 600, far: 1000
              )
            ]
          )
        }
        at(1) do
          check_screenshot(File.join(__dir__, "bullet_1.png"))
        end
        at(5) { check_screenshot(File.join(__dir__, "bullet_2.png")) }
        at(30) do
          check_screenshot(File.join(__dir__, "bullet_3.png"))
          Engine.stop_game
        end
      end
    end
  end
end
