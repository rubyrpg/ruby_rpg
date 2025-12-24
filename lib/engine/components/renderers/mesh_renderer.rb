# frozen_string_literal: true

module Engine::Components
  class MeshRenderer < Engine::Component
    attr_reader :mesh, :material, :static

    def initialize(mesh, material, static: false)
      @mesh = mesh
      @material = material
      @static = static
    end

    def renderer_key
      @renderer_key ||= [mesh, material].freeze
    end

    def renderer?
      true
    end

    def start
      Rendering::RenderPipeline.add_instance(self)
    end

    def sync_transform
      Rendering::RenderPipeline.update_instance(self) unless static
    end

    def destroy
      Rendering::RenderPipeline.remove_instance(self)
    end
  end
end
