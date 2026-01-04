# frozen_string_literal: true

module Asteroids
  module Ship
    def self.create(pos, rotation)
      ship = Engine::GameObject.create(
        name: "Ship",
        pos: pos,
        rotation: rotation,
        scale: Vector[50, 50, 1],
        components:
          [ShipEngine.create,
           ClampToScreen.new,
           Gun.new,
           Engine::Components::SpriteRenderer.new(ship_material)]
      )

      ship.add_child Engine::GameObject.create(
        name: "Shield",
        pos: Vector[0, 0, 0],
        rotation: Vector[0, 0, 0],
        scale: Vector[2, 2, 1],  # 2x parent size (100/50)
        components:
          [
            ShieldComponent.create,
            Engine::Components::SpriteRenderer.new(shield_material)
          ]
      )

      ship
    end

    def self.ship_material
      material = Engine::Material.create(shader: Engine::Shader.instanced_sprite)
      material.set_texture("image", Engine::Texture.for("assets/Player.png"))
      material.set_vec4("spriteColor", [1, 1, 1, 1])
      material
    end

    def self.shield_material
      material = Engine::Material.create(shader: Engine::Shader.instanced_sprite)
      material.set_texture("image", Engine::Texture.for("assets/Shield.png"))
      material.set_vec4("spriteColor", [1, 1, 1, 1])
      material
    end
  end
end
