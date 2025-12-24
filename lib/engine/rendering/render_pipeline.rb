# frozen_string_literal: true

module Rendering
  module RenderPipeline
    def self.draw
      update_render_texture_size
      sync_transforms

      enable_depth_test
      draw_shadow_maps

      render_texture_a.bind
      clear_buffer
      draw_3d
      render_texture_a.unbind

      current_texture = PostProcessingEffect.apply_all(render_texture_a, render_texture_b, screen_quad)

      disable_depth_test
      current_texture.bind
      draw_ui
      current_texture.unbind

      blit_to_screen(current_texture.texture)
    end

    def self.draw_shadow_maps
      # Render directional light shadows to shared texture array
      directional_casters = Engine::Components::DirectionLight.direction_lights
        .select(&:cast_shadows)
        .take(4)
      directional_casters.each_with_index do |light, layer_index|
        light.shadow_layer_index = layer_index
        render_shadow_map_to_layer(directional_shadow_map_array, layer_index, light.light_space_matrix)
      end

      # Render spot light shadows to shared texture array
      spot_casters = Engine::Components::SpotLight.spot_lights
        .select(&:cast_shadows)
        .take(4)
      spot_casters.each_with_index do |light, layer_index|
        light.shadow_layer_index = layer_index
        render_shadow_map_to_layer(spot_shadow_map_array, layer_index, light.light_space_matrix)
      end

      # Render point light shadows (still uses individual cubemaps)
      Engine::Components::PointLight.shadow_casting_lights.each do |light|
        render_point_light_shadow_map(light)
      end

      reset_viewport
    end

    def self.directional_shadow_map_array
      @directional_shadow_map_array ||= ShadowMapArray.new(layer_count: 4)
    end

    def self.spot_shadow_map_array
      @spot_shadow_map_array ||= ShadowMapArray.new(layer_count: 4)
    end

    def self.render_shadow_map_to_layer(shadow_map_array, layer_index, light_space_matrix)
      shadow_map_array.bind_layer(layer_index)
      instance_renderers.values.each do |renderer|
        renderer.draw_depth_only(light_space_matrix)
      end
      shadow_map_array.unbind
    end

    def self.render_point_light_shadow_map(light)
      light_pos = light.position
      far_plane = light.shadow_far
      matrices = light.light_space_matrices

      6.times do |face_index|
        light.shadow_map.bind_face(face_index)
        instance_renderers.values.each do |renderer|
          renderer.draw_point_light_depth(matrices[face_index], light_pos, far_plane)
        end
      end
      light.shadow_map.unbind
    end

    def self.sync_transforms
      Engine::GameObject.mesh_renderers.each do |renderer|
        renderer.sync_transform if renderer.respond_to?(:sync_transform)
      end
    end

    def self.draw_3d
      instance_renderers.values.each(&:draw_all)
    end

    def self.draw_ui
      Engine::GameObject.ui_renderers.each(&:draw)
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
      reset_viewport
      screen_quad.draw(blit_material, texture)
    end

    def self.enable_depth_test
      GL.Enable(GL::DEPTH_TEST)
      GL.DepthFunc(GL::LESS)
    end

    def self.disable_depth_test
      GL.Disable(GL::DEPTH_TEST)
    end

    def self.reset_viewport
      GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
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
