# frozen_string_literal: true

module Asteroids
  module Asteroid
    def self.create(pos, rotation, radius)
      Engine::GameObject.new(
        "Asteroid",
        pos: pos,
        rotation: rotation,
        scale: Vector[radius, radius, 1],
        components:
          [AsteroidComponent.new(radius),
           ConstantDrift.new(rand(150)),
           ClampToScreen.new,
           Engine::Components::SpriteRenderer.new(asteroid_material)]
      )
    end

    def self.asteroid_material
      material = Engine::Material.new(Engine::Shader.instanced_sprite)
      material.set_texture("image", Engine::Texture.for("assets/Asteroid_01.png"))
      material.set_vec4("spriteColor", [1, 1, 1, 1])
      material
    end
  end
end
