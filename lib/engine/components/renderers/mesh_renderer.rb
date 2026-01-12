# frozen_string_literal: true

module Engine::Components
  class MeshRenderer < Engine::Component
    serialize :mesh, :material, :static

    attr_reader :mesh, :material, :static

    def awake
      @static = false if @static.nil?
      @last_synced_version = nil
      @renderer_key = nil
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
      return if static

      version = game_object.world_transform_version
      return if @last_synced_version == version

      @last_synced_version = version
      Rendering::RenderPipeline.update_instance(self)
    end

    def destroy
      Rendering::RenderPipeline.remove_instance(self)
    end
  end
end
