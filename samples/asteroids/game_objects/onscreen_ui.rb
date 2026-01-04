# frozen_string_literal: true

module Asteroids
  module OnscreenUI
    TEXT_SIZE = 30
    UI_Z_ORDER = 0

    def self.create
      parent = Engine::GameObject.create(name: "FPS Counter Container")
      parent.add_child Text.create(Vector[TEXT_SIZE, Engine::Window.height - TEXT_SIZE, UI_Z_ORDER], 0, TEXT_SIZE, "FPS: ", components: [ Asteroids::FpsComponent.new ])
    end
  end
end
