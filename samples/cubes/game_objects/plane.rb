# frozen_string_literal: true

module Cubes
  module Plane
    def self.create(pos, rotation, size, texture = nil, normal = nil)
      Engine::GameObject.new(
        "Plane",
        pos: pos,
        rotation: rotation,
        scale: Vector[size, size, size],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for("assets/plane"), material(texture, normal)),
        ]
      )
    end

    private

    def self.material(texture = nil, normal = nil)
          material = Engine::Material.new(Engine::Shader.default)
          material.set_texture("image", texture || Engine::Texture.for("assets/tiles.png").texture)
          material.set_texture("normalMap", normal)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.5)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.02, 0.02, 0.02])
          material
    end
  end
end
