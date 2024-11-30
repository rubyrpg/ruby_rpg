# frozen_string_literal: true

module Cubes
  module Teapot
    def self.create(pos, rotation, size)
      Engine::GameObject.new(
        "Cube",
        pos: pos,
        rotation: rotation,
        scale: Vector[size, size, size],
        components: [
          Engine::Components::MeshRenderer.new(
            Engine::Mesh.for("assets/teapot"),
            material,
          ),
        ]
      )
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.default)
          material.set_texture("image", Engine::Texture.for("assets/chessboard.png").texture)
          material.set_texture("normalMap", Engine::Texture.for("assets/brick_normal.png").texture)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.7)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.1, 0.1, 0.1])
          material
        end
    end
  end
end
