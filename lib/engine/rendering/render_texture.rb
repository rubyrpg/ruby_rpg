# frozen_string_literal: true

module Rendering
  class RenderTexture
    attr_reader :width, :height, :framebuffer, :depth_stencil_texture, :color_textures

    def initialize(width, height, num_color_attachments: 1)
      @width = width
      @height = height
      @num_color_attachments = num_color_attachments
      @color_textures = []
      create_framebuffer
      create_color_textures
      create_depth_stencil_texture
      attach_to_framebuffer
      check_framebuffer_complete
      unbind
    end

    def color_texture
      @color_textures[0]
    end

    # Accessor for normal+roughness texture (second attachment)
    def normal_texture
      @color_textures[1]
    end

    # Alias for backward compatibility (depth can still be sampled from depth-stencil)
    alias depth_texture depth_stencil_texture

    def bind
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      Engine::GL.Viewport(0, 0, @width, @height)
    end

    def unbind
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, 0)
    end

    def resize(width, height)
      return if width == @width && height == @height

      @width = width
      @height = height

      @color_textures.each do |tex|
        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, tex)
        Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA16F, @width, @height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
      end

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @depth_stencil_texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::DEPTH24_STENCIL8, @width, @height, 0, Engine::GL::DEPTH_STENCIL, Engine::GL::UNSIGNED_INT_24_8, nil)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_color_textures
      @num_color_attachments.times do
        tex_buf = ' ' * 4
        Engine::GL.GenTextures(1, tex_buf)
        texture = tex_buf.unpack1('L')

        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, texture)
        Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA16F, @width, @height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)

        @color_textures << texture
      end
    end

    def create_depth_stencil_texture
      tex_buf = ' ' * 4
      Engine::GL.GenTextures(1, tex_buf)
      @depth_stencil_texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @depth_stencil_texture)
      Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::DEPTH24_STENCIL8, @width, @height, 0, Engine::GL::DEPTH_STENCIL, Engine::GL::UNSIGNED_INT_24_8, nil)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)
      # Disable depth comparison for direct sampling
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_COMPARE_MODE, Engine::GL::NONE)
      # Specify we want to read depth component (not stencil)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::DEPTH_STENCIL_TEXTURE_MODE, Engine::GL::DEPTH_COMPONENT)
    end

    def attach_to_framebuffer
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)

      # Attach all color textures
      @color_textures.each_with_index do |tex, i|
        Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::COLOR_ATTACHMENT0 + i, Engine::GL::TEXTURE_2D, tex, 0)
      end

      # Attach depth-stencil texture
      Engine::GL.FramebufferTexture2D(Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_STENCIL_ATTACHMENT, Engine::GL::TEXTURE_2D, @depth_stencil_texture, 0)

      # Tell OpenGL which color attachments to draw to (MRT)
      if @num_color_attachments > 1
        attachments = (0...@num_color_attachments).map { |i| Engine::GL::COLOR_ATTACHMENT0 + i }
        Engine::GL.DrawBuffers(@num_color_attachments, attachments.pack('L*'))
      end
    end

    def check_framebuffer_complete
      status = Engine::GL.CheckFramebufferStatus(Engine::GL::FRAMEBUFFER)
      unless status == Engine::GL::FRAMEBUFFER_COMPLETE
        raise "Framebuffer not complete: #{status}"
      end
    end
  end
end
