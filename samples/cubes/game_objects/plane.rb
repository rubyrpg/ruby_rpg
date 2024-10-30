# frozen_string_literal: true

module Cubes
  module Plane
    def self.create(pos, rotation, size)
      Engine::GameObject.new(
        "Plane",
        pos: pos,
        rotation: rotation,
        scale: Vector[size, size, size],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for("assets/plane"), material),
        ]
      )
    end

    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.new('./shaders/mesh_vertex.glsl', './shaders/mesh_frag.glsl'))
          material.set_texture("image", Engine::Texture.for("assets/tiles.png").texture)
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.5)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.1, 0.1, 0.1])
          material
        end
    end
  end
end
