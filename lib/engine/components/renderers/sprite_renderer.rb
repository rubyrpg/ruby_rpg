# frozen_string_literal: true

module Engine::Components
  class SpriteRenderer < Engine::Component
    attr_reader :material

    def initialize(material)
      @material = material
    end

    def colour=(value)
      material.set_vec4("spriteColor", colour_to_vec4(value))
    end

    def colour_to_vec4(value)
      if value.is_a?(Array)
        value
      else
        [value[:r], value[:g], value[:b], value[:a] || 1.0]
      end
    end

    def renderer?
      true
    end

    def start
      @mesh_renderer = MeshRenderer.new(Engine::Mesh.quad, material)
      @mesh_renderer.set_game_object(game_object)
      @mesh_renderer.start
      set_default_frame_coords
    end

    def sync_transform
      @mesh_renderer.sync_transform
    end

    def destroy
      @mesh_renderer.destroy
    end

    private

    def set_default_frame_coords
      material.set_vec4("frameCoords", [0, 0, 1, 1])
    end
  end
end
