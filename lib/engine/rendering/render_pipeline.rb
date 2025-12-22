# frozen_string_literal: true

module Rendering
  module RenderPipeline
    def self.draw
      update_render_texture_size

      render_texture.bind
      clear_buffer
      draw_3d
      draw_ui
      render_texture.unbind

      blit_to_screen
    end

    def self.draw_3d
      GL.Enable(GL::DEPTH_TEST)
      GL.DepthFunc(GL::LESS)

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

    def self.clear_buffer
      GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    end

    def self.blit_to_screen
      GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
      GL.Disable(GL::DEPTH_TEST)
      screen_quad.draw(render_texture.texture)
    end

    def self.update_render_texture_size
      render_texture.resize(Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
    end

    def self.render_texture
      @render_texture ||= RenderTexture.new(Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
    end

    def self.screen_quad
      @screen_quad ||= ScreenQuad.new
    end

    def self.instance_renderers
      @instance_renderers ||= Hash.new do |hash, key|
        hash[key] = InstanceRenderer.new(key[0], key[1])
      end
    end
  end
end
