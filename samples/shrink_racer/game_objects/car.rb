# frozen_string_literal: true

module ShrinkRacer
  module Car
    def self.create_suv(pos, rotation)
      spinner = SpinEffect.new
      parent = Engine::GameObject.new(
        "Car",
        pos: pos,
        rotation: rotation,
        scale: Vector[0.1, 0.1, 0.1],
        components: [
          CarCollider.new(1.0),
          CarController.new(spinner),
        ]
      )
      Engine::GameObject.new(
        "SUV",
        pos: Vector[0, 0, 0],
        rotation: Vector[0, 0, 0],
        scale: Vector[1, 1, 1],
        components: [
          spinner,
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/cars/suv"), material),
        ],
        parent: parent
      )
      parent
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.default)
          material.set_texture("image", Engine::Texture.for("assets/cars/Textures/colormap.png", flip: true).texture)
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.6)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.5, 0.5, 0.5])
          material
        end
    end
  end
end
