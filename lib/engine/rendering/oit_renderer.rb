# frozen_string_literal: true

module Rendering
  module OitRenderer
    # Returns the render texture containing the composited result.
    # scene_rt: render texture with the current scene (after skybox)
    # output_rt: alternate render texture to composite into
    # depth_rt: render texture whose depth buffer to use for depth testing
    # The opaque scene texture, available for transparent shaders to sample
    def self.opaque_scene_texture
      @opaque_scene_texture
    end

    def self.draw(scene_rt, output_rt, depth_rt, screen_quad, instance_renderers)
      return scene_rt unless has_transparent_renderers?(instance_renderers)

      ensure_targets_created
      resize_if_needed

      @opaque_scene_texture = scene_rt.color_texture
      draw_accumulation_pass(depth_rt, instance_renderers)
      composite(scene_rt, output_rt, screen_quad)
      output_rt
    end

    private

    def self.has_transparent_renderers?(instance_renderers)
      instance_renderers.values.any? { |r| r.material.transparent? }
    end

    def self.ensure_targets_created
      return if @fbo

      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @fbo = fbo_buf.unpack1('L')

      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height

      @accum_texture = create_texture(width, height, Engine::GL::RGBA16F, Engine::GL::RGBA, Engine::GL::FLOAT)
      @reveal_texture = create_texture(width, height, Engine::GL::R16F, Engine::GL::RED, Engine::GL::FLOAT)

      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @fbo)
      Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT0, Engine::GL::TEXTURE_2D, @accum_texture, 0)
      Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT1, Engine::GL::TEXTURE_2D, @reveal_texture, 0)

      Engine::GL.DrawBuffers(2, [Engine::GL::COLOR_ATTACHMENT0, Engine::GL::COLOR_ATTACHMENT1].pack('L*'))

      status = Engine::GL.CheckFramebufferStatus(Engine::GL::FRAMEBUFFER)
      raise "OIT framebuffer not complete: #{status}" unless status == Engine::GL::FRAMEBUFFER_COMPLETE

      @width = width
      @height = height
    end

    def self.create_texture(width, height, internal_format, format, type)
      tex_buf = ' ' * 4
      Engine::GL.GenTextures(1, tex_buf)
      texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, internal_format, width, height, 0, format, type, nil)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)

      texture
    end

    def self.resize_if_needed
      width = Engine::Window.framebuffer_width
      height = Engine::Window.framebuffer_height
      return if @width == width && @height == height

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @accum_texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA16F, width, height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @reveal_texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::R16F, width, height, 0, Engine::GL::RED, Engine::GL::FLOAT, nil)

      @width = width
      @height = height
    end

    def self.draw_accumulation_pass(depth_rt, instance_renderers)
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @fbo)

      # Attach opaque depth buffer so transparent objects depth-test against opaque geometry
      Engine::GL.FramebufferTexture2D(
        Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_STENCIL_ATTACHMENT,
        Engine::GL::TEXTURE_2D, depth_rt.depth_stencil_texture, 0
      )

      Engine::GL.Viewport(0, 0, @width, @height)

      # Clear accumulation to (0,0,0,0)
      Engine::GL.ClearColor(0.0, 0.0, 0.0, 0.0)
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)

      # Clear revealage to 1.0
      Engine::GL.DrawBuffers(1, [Engine::GL::COLOR_ATTACHMENT1].pack('L*'))
      Engine::GL.ClearColor(1.0, 0.0, 0.0, 0.0)
      Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)

      # Restore drawing to both attachments
      Engine::GL.DrawBuffers(2, [Engine::GL::COLOR_ATTACHMENT0, Engine::GL::COLOR_ATTACHMENT1].pack('L*'))
      Engine::GL.ClearColor(0.0, 0.0, 0.0, 0.0)

      # OIT blend modes:
      # Accumulation (0): additive (ONE, ONE)
      # Revealage (1): multiplicative (ZERO, ONE_MINUS_SRC_COLOR)
      Engine::GL.Enable(Engine::GL::BLEND)
      Engine::GL.BlendFunci(0, Engine::GL::ONE, Engine::GL::ONE)
      Engine::GL.BlendFunci(1, Engine::GL::ZERO, Engine::GL::ONE_MINUS_SRC_COLOR)

      # Depth test ON, depth write OFF
      Engine::GL.Enable(Engine::GL::DEPTH_TEST)
      Engine::GL.DepthMask(Engine::GL::FALSE)

      instance_renderers.values.each do |renderer|
        next unless renderer.material.transparent?
        renderer.draw_transparent
      end

      # Restore state
      Engine::GL.DepthMask(Engine::GL::TRUE)
      Engine::GL.BlendFunc(Engine::GL::SRC_ALPHA, Engine::GL::ONE_MINUS_SRC_ALPHA)
    end

    def self.composite(scene_rt, output_rt, screen_quad)
      output_rt.bind
      Engine::GL.Disable(Engine::GL::DEPTH_TEST)

      composite_material.set_runtime_texture("accumTexture", @accum_texture)
      composite_material.set_runtime_texture("revealTexture", @reveal_texture)
      screen_quad.draw(composite_material, scene_rt.color_texture)

      Engine::GL.Enable(Engine::GL::DEPTH_TEST)
    end

    def self.composite_material
      @composite_material ||= Engine::Material.create(
        shader: Engine::Shader.for(
          'fullscreen_vertex.glsl',
          'oit_composite_frag.glsl',
          source: :engine
        )
      )
    end
  end
end
