# frozen_string_literal: true

module Rendering
  class RenderTexture
    attr_reader :width, :height, :framebuffer, :texture, :depth_texture

    def initialize(width, height)
      @width = width
      @height = height
      create_framebuffer
      create_texture
      create_depth_texture
      attach_to_framebuffer
      check_framebuffer_complete
      unbind
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

      GL.BindTexture(GL::TEXTURE_2D, @texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA, @width, @height, 0, GL::RGBA, GL::UNSIGNED_BYTE, nil)

      GL.BindTexture(GL::TEXTURE_2D, @depth_texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::DEPTH_COMPONENT32F, @width, @height, 0, GL::DEPTH_COMPONENT, GL::FLOAT, nil)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_texture
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_2D, @texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA, @width, @height, 0, GL::RGBA, GL::UNSIGNED_BYTE, nil)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)
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
      GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::COLOR_ATTACHMENT0, GL::TEXTURE_2D, @texture, 0)
      GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::TEXTURE_2D, @depth_texture, 0)
    end

    def check_framebuffer_complete
      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Framebuffer not complete: #{status}"
      end
    end
  end
end
