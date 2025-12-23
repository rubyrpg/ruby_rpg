# frozen_string_literal: true

module ShrinkRacer
  module Cube
    def self.create(pos, rotation, size)
      Engine::GameObject.new(
        "Cube",
        pos: pos,
        rotation: rotation,
        scale: Vector[size, size, size],
        components: [
          Engine::Components::MeshRenderer.new(Engine::Mesh.for(
            "assets/road_tiles/roadTile_001"), material),
        ]
      )
    end


    private

    def self.material
      @material ||=
        begin
          material = Engine::Material.new(Engine::Shader.default)
          material.set_texture("image", Engine::Texture.for("assets/chessboard.png").texture)
          material.set_texture("normalMap", nil)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 0.7)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.04, 0.025, 0.06])
          material
        end
    end

    def self.bumped_material
      @bumped_material ||=
        begin
          material = Engine::Material.new(Engine::Shader.default)
          material.set_texture("image", Engine::Texture.for("assets/chessboard.png").texture)
          material.set_texture("normalMap", Engine::Texture.for("assets/brick_normal.png").texture)
          material.set_float("diffuseStrength", 0.5)
          material.set_float("specularStrength", 1)
          material.set_float("specularPower", 32.0)
          material.set_vec3("ambientLight", Vector[0.04, 0.025, 0.06])
          material
        end
    end
  end
end
