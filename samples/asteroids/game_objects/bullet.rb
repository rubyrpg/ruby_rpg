# frozen_string_literal: true

module Asteroids
  module Bullet
    BULLET_SIZE = 5

    def self.create(pos, rotation)
      Engine::GameObject.new(
        "Bullet",
        pos: pos,
        rotation: rotation,
        components: [
          Projectile.new,
          ConstantDrift.new(900),
          DestroyAfter.new(2),
          Engine::Components::SpriteRenderer.new(
            Vector[-BULLET_SIZE / 2, BULLET_SIZE / 2],
            Vector[BULLET_SIZE / 2, BULLET_SIZE / 2],
            Vector[BULLET_SIZE / 2, -BULLET_SIZE / 2],
            Vector[-BULLET_SIZE / 2, -BULLET_SIZE / 2],
            Bullet.texture
          )
        ]
      )
    end

    def self.texture
      @texture ||= Engine::Texture.for("assets/Square.png").texture
    end
  end
end
