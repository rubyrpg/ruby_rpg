# frozen_string_literal: true

module Asteroids
  module Bullet
    BULLET_SIZE = 5

    def self.create(pos, rotation)
      Engine::GameObject.create(
        name: "Bullet",
        pos: pos,
        rotation: rotation,
        scale: Vector[BULLET_SIZE, BULLET_SIZE, 1],
        components: [
          Projectile.new,
          ConstantDrift.new(900),
          DestroyAfter.new(2),
          Engine::Components::SpriteRenderer.new(bullet_material)
        ]
      )
    end

    def self.bullet_material
      material = Engine::Material.new(Engine::Shader.instanced_sprite)
      material.set_texture("image", Engine::Texture.for("assets/Square.png"))
      material.set_vec4("spriteColor", [1, 1, 1, 1])
      material
    end
  end
end
