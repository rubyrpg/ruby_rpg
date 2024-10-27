# frozen_string_literal: true

module Engine::Components
  class MeshRenderer < Engine::Component
    attr_reader :mesh, :material, :static

    def initialize(mesh, material, static: false)
      @mesh = mesh
      @material = material
      @static = static
    end

    def renderer?
      true
    end

    def start
      Rendering::RenderPipeline.add_instance(self)
    end

    def update(delta_time)
      unless static
        Rendering::RenderPipeline.update_instance(self)
      end
    end

    def destroy
      Rendering::RenderPipeline.remove_instance(self)
    end
  end
end
