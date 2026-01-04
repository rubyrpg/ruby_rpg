# frozen_string_literal: true

module Engine
  module StandardObjects
    module Plane
      def self.create(pos: Vector[0, 0, 0], rotation: 0, scale: Vector[1, 1, 1], components: [], material: nil)
        Engine::GameObject.create(
          name: "Plane",
          pos: pos,
          rotation: rotation,
          scale: scale,
          components: [
            Engine::Components::MeshRenderer.new(
              Engine::Mesh.from_engine("plane"),
              material || StandardObjects.default_material
            ),
            *components
          ]
        )
      end
    end
  end
end
