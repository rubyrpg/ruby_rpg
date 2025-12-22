# frozen_string_literal: true

module Rendering
  module RenderPipeline
    def self.draw
      draw_3d
      draw_ui
    end

    def self.draw_3d
      Engine::GameObject.mesh_renderers.each do |mesh_renderer|
        mesh_renderer.update(0)
      end

      instance_renderers.values.each do |renderer|
        renderer.draw_all
      end
    end

    def self.draw_ui
      GL.Disable(GL::DEPTH_TEST)
      Engine::GameObject.ui_renderers.each do |ui_renderer|
        ui_renderer.update(0)
      end
      GL.Enable(GL::DEPTH_TEST)
    end

    def self.add_instance(mesh_renderer)
      instance_renderers[[mesh_renderer.mesh, mesh_renderer.material]].add_instance(mesh_renderer)
    end

    def self.remove_instance(mesh_renderer)
      instance_renderers[[mesh_renderer.mesh, mesh_renderer.material]].remove_instance(mesh_renderer)
    end

    def self.update_instance(mesh_renderer)
      instance_renderers[[mesh_renderer.mesh, mesh_renderer.material]].update_instance(mesh_renderer)
    end

    private

    def self.instance_renderers
      @instance_renderers ||= Hash.new do |hash, key|
        hash[key] = InstanceRenderer.new(key[0], key[1])
      end
    end
  end
end
