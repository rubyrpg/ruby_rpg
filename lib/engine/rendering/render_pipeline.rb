# frozen_string_literal: true

module Rendering
  module RenderPipeline
    def self.draw
      update_render_texture_size
      sync_transforms
      SkyboxRenderer.render_cubemap
      reset_viewport

      GpuTimer.measure(:shadows) do
        enable_depth_test
        draw_shadow_maps
      end

      GpuTimer.measure(:main_3d) do
        render_texture_a.bind
        clear_buffer
        Engine::GL.Disable(Engine::GL::BLEND)  # Disable blending to preserve alpha channel (roughness) in MRT
        draw_3d
        Engine::GL.Enable(Engine::GL::BLEND)   # Re-enable for UI and post-processing
      end

      # Copy normal texture to separate buffer to avoid read/write hazard in SSR
      copy_normal_texture

      GpuTimer.measure(:skybox) do
        SkyboxRenderer.draw(render_texture_a, render_texture_b, screen_quad)
      end

      current_texture = PostProcessingEffect.apply_all(render_texture_a, render_texture_b, screen_quad, normal_buffer, start_index: 1)

      GpuTimer.measure(:debug) do
        DebugDraw.draw(current_texture.framebuffer)
      end

      GpuTimer.measure(:ui) do
        disable_depth_test
        current_texture.bind
        draw_ui
      end

      GpuTimer.measure(:blit) do
        blit_to_screen(current_texture.color_texture)
      end

      GpuTimer.print_results
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

      # Render point light shadows to shared cubemap array
      point_casters = Engine::Components::PointLight.point_lights
        .select(&:cast_shadows)
        .take(4)
      point_casters.each_with_index do |light, layer_index|
        light.shadow_layer_index = layer_index
        render_point_shadow_to_layer(layer_index, light)
      end

      reset_viewport
    end

    def self.directional_shadow_map_array
      @directional_shadow_map_array ||= ShadowMapArray.new(layer_count: 4)
    end

    def self.spot_shadow_map_array
      @spot_shadow_map_array ||= ShadowMapArray.new(layer_count: 4)
    end

    def self.point_shadow_map_array
      @point_shadow_map_array ||= CubemapShadowMapArray.new(layer_count: 4)
    end

    def self.render_shadow_map_to_layer(shadow_map_array, layer_index, light_space_matrix)
      shadow_map_array.bind_layer(layer_index)
      instance_renderers.values.each do |renderer|
        renderer.draw_depth_only(light_space_matrix)
      end
    end

    def self.render_point_shadow_to_layer(layer_index, light)
      light_pos = light.position
      far_plane = light.shadow_far
      matrices = light.light_space_matrices

      6.times do |face_index|
        point_shadow_map_array.bind_face(layer_index, face_index)
        instance_renderers.values.each do |renderer|
          renderer.draw_point_light_depth(matrices[face_index], light_pos, far_plane)
        end
      end
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
      Engine::GL.Clear(Engine::GL::STENCIL_BUFFER_BIT)
      Engine::GL.Disable(Engine::GL::CULL_FACE)
      Engine::Components::UI::Rect.draw_all
      Engine::GL.Enable(Engine::GL::CULL_FACE)
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

    def self.set_skybox_colors(ground:, horizon:, sky:, ground_y: -0.3, horizon_y: 0.0, sky_y: 1.0)
      SkyboxRenderer.set_colors(ground: ground, horizon: horizon, sky: sky, ground_y: ground_y, horizon_y: horizon_y, sky_y: sky_y)
    end

    def self.skybox_cubemap
      SkyboxRenderer.cubemap
    end

    private

    def self.alternate_rt(current_rt)
      current_rt == render_texture_a ? render_texture_b : render_texture_a
    end

    def self.clear_buffer
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT | Engine::GL::DEPTH_BUFFER_BIT)
    end

    def self.blit_to_screen(texture)
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, 0)
      reset_viewport
      screen_quad.draw(blit_material, texture)
    end

    def self.enable_depth_test
      Engine::GL.Enable(Engine::GL::DEPTH_TEST)
      Engine::GL.DepthFunc(Engine::GL::LESS)
    end

    def self.disable_depth_test
      Engine::GL.Disable(Engine::GL::DEPTH_TEST)
    end

    def self.reset_viewport
      Engine::GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
    end

    def self.blit_material
      @blit_material ||= Engine::Material.create(shader: Engine::Shader.fullscreen)
    end

    def self.update_render_texture_size
      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height
      render_texture_a.resize(width, height)
      render_texture_b.resize(width, height)
      resize_normal_buffer(width, height)
    end

    def self.normal_buffer
      @normal_buffer ||= create_normal_buffer
    end

    def self.create_normal_buffer
      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height

      tex_buf = ' ' * 4
      Engine::GL.GenTextures(1, tex_buf)
      texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA16F, width, height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)

      @normal_buffer_width = width
      @normal_buffer_height = height
      texture
    end

    def self.resize_normal_buffer(width, height)
      return if @normal_buffer_width == width && @normal_buffer_height == height
      return unless @normal_buffer

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @normal_buffer)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA16F, width, height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
      @normal_buffer_width = width
      @normal_buffer_height = height
    end

    def self.copy_normal_texture
      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height

      # Bind source (render_texture_a's normal attachment) as read framebuffer
      Engine::GL.BindFramebuffer(Engine::GL::READ_FRAMEBUFFER, render_texture_a.framebuffer)
      Engine::GL.ReadBuffer(Engine::GL::COLOR_ATTACHMENT1)  # Normal is second attachment

      # Bind destination texture to a temp framebuffer for writing
      Engine::GL.BindFramebuffer(Engine::GL::DRAW_FRAMEBUFFER, copy_fbo)
      Engine::GL.FramebufferTexture2D(Engine::GL::DRAW_FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT0, Engine::GL::TEXTURE_2D, normal_buffer, 0)

      # Blit
      Engine::GL.BlitFramebuffer(0, 0, width, height, 0, 0, width, height, Engine::GL::COLOR_BUFFER_BIT, Engine::GL::NEAREST)
    end

    def self.copy_fbo
      return @copy_fbo if @copy_fbo

      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @copy_fbo = fbo_buf.unpack1('L')
    end

    def self.render_texture_a
      @render_texture_a ||= RenderTexture.new(
        Engine::Window.framebuffer_width,
        Engine::Window.framebuffer_height,
        num_color_attachments: 2  # Color + Normal/Roughness for SSR
      )
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
