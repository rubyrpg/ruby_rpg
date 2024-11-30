# frozen_string_literal: true

module ShrinkRacer
  module Props
    def self.create_cone(pos, rotation)
      parent = Engine::GameObject.new(
        "Cone",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1],
        components: [
          TreeCollider.new(0.05),
        ]
      )
      Engine::GameObject.new(
        "Cone",
        pos: Vector[0, 0.023, 0],
        rotation: Vector[0, rand(0..360), 0],
        scale: Vector[0.3, 0.3, 0.3],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/cars/cone"), cone_material, static: true),
        ],
        parent: parent
      )
      parent
    end

    def self.create_coin(pos, rotation)
      parent = Engine::GameObject.new(
        "Coin",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1],
        components: [
          CoinCollider.new(0.075)
        ]
      )
      Engine::GameObject.new(
        "Coin",
        pos: Vector[0, 0.023, 0],
        rotation: Vector[0, rand(0..360), 0],
        scale: Vector[0.5, 0.5, 0.3],
        components: [
          Spinner.new,
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/props/coin"), coin_material),
        ],
        parent: parent
      )
      parent
    end

    private

    def self.cone_material
      @cone_material ||= material("cars/Textures/colormap.png")
    end

    def self.coin_material
      @coin_material ||= material("props/Textures/colormap.png")
    end

    def self.material(texture_file)
      material = Engine::Material.new(Engine::Shader.default)
      material.set_texture("image", Engine::Texture.for(File.join("assets", texture_file), flip: true).texture)
      material.set_texture("normalMap", nil)
      material.set_float("diffuseStrength", 0.5)
      material.set_float("specularStrength", 0.6)
      material.set_float("specularPower", 32.0)
      material.set_vec3("ambientLight", Vector[0.7, 0.7, 0.7])
      material
    end
  end
end
