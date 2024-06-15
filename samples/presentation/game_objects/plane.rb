# frozen_string_literal: true

module Presentation
  module Plane
    def self.create(pos, rotation, size)
      Engine::GameObject.new(
        "Plane",
        pos: pos,
        rotation: rotation,
        scale: Vector[size, size, size],
        components: [
          Engine::Components::MeshRenderer.new(
            Engine::Mesh.for("assets/plane"),
            Engine::Texture.for(ASSETS_DIR + "/Arial.png").texture,
            ambient_light: Vector[1,1,1]
          ),
        ]
      )
    end
  end
end