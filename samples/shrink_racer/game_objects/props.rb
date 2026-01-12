# frozen_string_literal: true

module ShrinkRacer
  module Props
    def self.create_cone(pos, rotation)
      parent = Engine::GameObject.create(
        name: "Cone",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1],
        components: [
          TreeCollider.new(0.05),
        ]
      )
      Engine::GameObject.create(
        name: "Cone",
        pos: Vector[0, 0.023, 0],
        rotation: Vector[0, rand(0..360), 0],
        scale: Vector[0.3, 0.3, 0.3],
        components: [
          Engine::Components::MeshRenderer.create(
            mesh: Engine::Mesh.for("assets/cars/cone"),
            material: cone_material,
            static: true
          ),
        ],
        parent: parent
      )
      parent
    end

    def self.create_coin(pos, rotation)
      parent = Engine::GameObject.create(
        name: "Coin",
        pos: pos,
        rotation: rotation,
        scale: Vector[1, 1, 1],
        components: [
          CoinCollider.new(0.075)
        ]
      )
      Engine::GameObject.create(
        name: "Coin",
        pos: Vector[0, 0.023, 0],
        rotation: Vector[0, rand(0..360), 0],
        scale: Vector[0.5, 0.5, 0.3],
        components: [
          Spinner.create,
          Engine::Components::MeshRenderer.create(
            mesh: Engine::Mesh.for("assets/props/coin"),
            material: coin_material
          ),
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
      @coin_material ||= begin
        material = Engine::Material.create(shader: Engine::Shader.default)
        material.set_texture("image", Engine::Texture.for("assets/props/Textures/colormap.png", flip: true))
        material.set_texture("normalMap", nil)
        material.set_float("diffuseStrength", 0.1)
        material.set_float("specularStrength", 0.1)
        material.set_float("specularPower", 32.0)
        material.set_vec3("ambientLight", Vector[0.8, 0.7, 0.5])
        material
      end
    end

    def self.material(texture_file)
      material = Engine::Material.create(shader: Engine::Shader.default)
      material.set_texture("image", Engine::Texture.for(File.join("assets", texture_file), flip: true))
      material.set_texture("normalMap", nil)
      material.set_float("diffuseStrength", 0.5)
      material.set_float("specularStrength", 0.6)
      material.set_float("specularPower", 32.0)
      material.set_vec3("ambientLight", Vector[0.17, 0.15, 0.22])
      material
    end
  end
end
