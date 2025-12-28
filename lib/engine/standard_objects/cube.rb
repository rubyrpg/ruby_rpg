# frozen_string_literal: true

module Engine
  module StandardObjects
    module Cube
      def self.create(pos: Vector[0, 0, 0], rotation: 0, scale: Vector[1, 1, 1], components: [], material: nil)
        Engine::GameObject.new(
          "Cube",
          pos: pos,
          rotation: rotation,
          scale: scale,
          components: [
            Engine::Components::MeshRenderer.new(
              Engine::Mesh.from_engine("cube"),
              material || StandardObjects.default_material
            ),
            *components
          ]
        )
      end
    end
  end
end
