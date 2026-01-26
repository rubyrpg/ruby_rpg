# frozen_string_literal: true

require_relative "../../../../samples/asteroids/game_objects/explosion"

include TestDriver

describe Asteroids::Explosion, :system do
  before do
    stub_const("GAME_DIR", File.expand_path(File.join(__dir__, "..", "..", "..", "..", "samples", "asteroids")))
  end

  describe "When placed in the scene" do
    it "renders the explosion" do
      within_game_context(frame_duration: 0.05, load_path: "./samples/asteroids") do
        at(0) do
          Asteroids::Explosion.create(Vector[100, 100])
          Engine::GameObject.create(
            name: "Camera",
            pos: Vector[800/2, 600/2, 0],
            components: [
              Engine::Components::OrthographicCamera.create(
                width: 800, height: 600, far: 1000
              )
            ]
          )
          check_screenshot(File.join(__dir__, "explosion_0.png"))
        end
        till(4) { check_screenshot(File.join(__dir__, "explosion_#{current_tick}.png")) }
        at(5) { Engine.stop_game }
      end
    end
  end
end
