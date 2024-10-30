# frozen_string_literal: true

module Asteroids
  module Ship
    def self.create(pos, rotation)
      ship = Engine::GameObject.new(
        "Ship",
        pos: pos,
        rotation: rotation,
        components:
          [ShipEngine.new,
           ClampToScreen.new,
           Gun.new,
           Engine::Components::SpriteRenderer.new(
             Vector[-25, 25], Vector[25, 25], Vector[25, -25], Vector[-25, -25],
             Engine::Texture.for(File.join("assets", "Player.png")).texture
           )]
      )

      ship.add_child Engine::GameObject.new(
        "Shield",
        pos: Vector[0, 0, 0],
        rotation: Vector[0, 0, 0],
        components:
          [
            ShieldComponent.new,
            Engine::Components::SpriteRenderer.new(
              Vector[-50, 50],
              Vector[50, 50],
              Vector[50, -50],
              Vector[-50, -50],
              Engine::Texture.for(File.join("assets", "Shield.png")).texture
            )
          ]
      )

      ship
    end
  end
end
