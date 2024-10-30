# frozen_string_literal: true

module Asteroids
  module Asteroid
    def self.create(pos, rotation, radius)
      Engine::GameObject.new(
        "Asteroid",
        pos: pos,
        rotation: rotation,
        components:
          [AsteroidComponent.new(radius),
           ConstantDrift.new(rand(150)),
           ClampToScreen.new,
           Engine::Components::SpriteRenderer.new(
             Vector[-radius / 2, radius / 2],
             Vector[radius / 2, radius / 2],
             Vector[radius / 2, -radius / 2],
             Vector[-radius / 2, -radius / 2],
             Asteroid.asteroid_texture
           )]
      )
    end

    private

    def self.asteroid_texture
      @asteroid_texture ||= Engine::Texture.for("assets/Asteroid_01.png").texture
    end
  end
end
