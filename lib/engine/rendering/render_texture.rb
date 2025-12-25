# frozen_string_literal: true

module Rendering
  class RenderTexture
    attr_reader :width, :height, :framebuffer, :depth_texture, :color_textures

    def initialize(width, height, num_color_attachments: 1)
      @width = width
      @height = height
      @num_color_attachments = num_color_attachments
      @color_textures = []
      create_framebuffer
      create_color_textures
      create_depth_texture
      attach_to_framebuffer
      check_framebuffer_complete
      unbind
    end

    # Backwards compatible accessor for first color attachment
    def texture
      @color_textures[0]
    end

    # Accessor for normal+roughness texture (second attachment)
    def normal_texture
      @color_textures[1]
    end

    def bind
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.Viewport(0, 0, @width, @height)
    end

    def unbind
      GL.BindFramebuffer(GL::FRAMEBUFFER, 0)
    end

    def resize(width, height)
      return if width == @width && height == @height

      @width = width
      @height = height

      @color_textures.each do |tex|
        GL.BindTexture(GL::TEXTURE_2D, tex)
        GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA16F, @width, @height, 0, GL::RGBA, GL::FLOAT, nil)
      end

      GL.BindTexture(GL::TEXTURE_2D, @depth_texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::DEPTH_COMPONENT32F, @width, @height, 0, GL::DEPTH_COMPONENT, GL::FLOAT, nil)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_color_textures
      @num_color_attachments.times do
        tex_buf = ' ' * 4
        GL.GenTextures(1, tex_buf)
        texture = tex_buf.unpack1('L')

        GL.BindTexture(GL::TEXTURE_2D, texture)
        GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA16F, @width, @height, 0, GL::RGBA, GL::FLOAT, nil)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)

        @color_textures << texture
      end
    end

    def create_depth_texture
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_2D, @depth_texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::DEPTH_COMPONENT32F, @width, @height, 0, GL::DEPTH_COMPONENT, GL::FLOAT, nil)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)
      # Disable depth comparison for direct sampling
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_COMPARE_MODE, GL::NONE)
      # Specify we want to read depth component (not stencil)
      GL.TexParameteri(GL::TEXTURE_2D, GL::DEPTH_STENCIL_TEXTURE_MODE, GL::DEPTH_COMPONENT)
    end

    def attach_to_framebuffer
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)

      # Attach all color textures
      @color_textures.each_with_index do |tex, i|
        GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::COLOR_ATTACHMENT0 + i, GL::TEXTURE_2D, tex, 0)
      end

      # Attach depth texture
      GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::TEXTURE_2D, @depth_texture, 0)

      # Tell OpenGL which color attachments to draw to (MRT)
      if @num_color_attachments > 1
        attachments = (0...@num_color_attachments).map { |i| GL::COLOR_ATTACHMENT0 + i }
        GL.DrawBuffers(@num_color_attachments, attachments.pack('L*'))
      end
    end

    def check_framebuffer_complete
      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Framebuffer not complete: #{status}"
      end
    end
  end
end
