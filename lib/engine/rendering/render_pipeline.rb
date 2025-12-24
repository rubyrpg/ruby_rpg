# frozen_string_literal: true

module Rendering
  module RenderPipeline
    def self.draw
      update_render_texture_size

      draw_shadow_maps

      render_texture_a.bind
      clear_buffer
      draw_3d
      render_texture_a.unbind

      current_texture = PostProcessingEffect.apply_all(render_texture_a, render_texture_b, screen_quad)

      current_texture.bind
      draw_ui
      current_texture.unbind

      blit_to_screen(current_texture.texture)
    end

    def self.draw_shadow_maps
      GL.Enable(GL::DEPTH_TEST)
      GL.DepthFunc(GL::LESS)

      shadow_casting_lights.each do |light|
        render_shadow_map(light)
      end

      GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
    end

    def self.shadow_casting_lights
      [
        *Engine::Components::DirectionLight.direction_lights,
        *Engine::Components::SpotLight.spot_lights
      ].select { |light| light.cast_shadows && light.shadow_map }
    end

    def self.render_shadow_map(light)
      light.shadow_map.bind
      instance_renderers.values.each do |renderer|
        renderer.draw_depth_only(light.light_space_matrix)
      end
      light.shadow_map.unbind
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
      instance_renderers[mesh_renderer.renderer_key].add_instance(mesh_renderer)
    end

    def self.remove_instance(mesh_renderer)
      instance_renderers[mesh_renderer.renderer_key].remove_instance(mesh_renderer)
    end

    def self.update_instance(mesh_renderer)
      instance_renderers[mesh_renderer.renderer_key].update_instance(mesh_renderer)
    end

    private

    def self.clear_buffer
      GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    end

    def self.blit_to_screen(texture)
      GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
      GL.Disable(GL::DEPTH_TEST)
      screen_quad.draw(blit_material, texture)
    end

    def self.blit_material
      @blit_material ||= Engine::Material.new(Engine::Shader.fullscreen)
    end

    def self.update_render_texture_size
      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height
      render_texture_a.resize(width, height)
      render_texture_b.resize(width, height)
    end

    def self.render_texture_a
      @render_texture_a ||= RenderTexture.new(Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
    end

    def self.render_texture_b
      @render_texture_b ||= RenderTexture.new(Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
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
