# frozen_string_literal: true

module Asteroids
  module Explosion
    EXPLOSION_FRAMES = [
      { tl: Vector[1.0 / 6, 0], width: 1.0 / 6, height: 1 },
      { tl: Vector[2.0 / 6, 0], width: 1.0 / 6, height: 1 },
      { tl: Vector[3.0 / 6, 0], width: 1.0 / 6, height: 1 },
      { tl: Vector[4.0 / 6, 0], width: 1.0 / 6, height: 1 },
      { tl: Vector[5.0 / 6, 0], width: 1.0 / 6, height: 1 },
      { tl: Vector[0, 0], width: 1.0 / 6, height: 1 },
    ]

    def self.create(pos, colour: [1, 1, 1, 1])
      material = explosion_material(colour)
      Engine::GameObject.create(
        name: "Explosion",
        pos: pos,
        scale: Vector[200, 200, 1],
        components: [
          Engine::Components::SpriteAnimator.new(
            material,
            frame_coords: EXPLOSION_FRAMES,
            frame_rate: 20,
            loop: false
          ),
          Engine::Components::SpriteRenderer.create(material: material),
          DestroyAfter.new(1)
        ]
      )
    end

    def self.explosion_material(colour)
      material = Engine::Material.create(shader: Engine::Shader.instanced_sprite)
      material.set_texture("image", Engine::Texture.for("assets/boom.png"))
      material.set_vec4("spriteColor", colour)
      material
    end
  end
end
