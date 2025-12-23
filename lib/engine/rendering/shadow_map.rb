# frozen_string_literal: true

module Rendering
  class ShadowMap
    attr_reader :width, :height, :framebuffer, :depth_texture

    def initialize(width = 2048, height = 2048)
      @width = width
      @height = height
      create_framebuffer
      create_depth_texture
      attach_to_framebuffer
      check_framebuffer_complete
      unbind
    end

    def bind
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.Viewport(0, 0, @width, @height)
      GL.Clear(GL::DEPTH_BUFFER_BIT)
    end

    def unbind
      GL.BindFramebuffer(GL::FRAMEBUFFER, 0)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_depth_texture
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_2D, @depth_texture)
      GL.TexImage2D(GL::TEXTURE_2D, 0, GL::DEPTH_COMPONENT32F, @width, @height, 0, GL::DEPTH_COMPONENT, GL::FLOAT, nil)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_BORDER)
      GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_BORDER)
      # Set border color to 1.0 (max depth) so areas outside shadow map are not shadowed
      border_color = [1.0, 1.0, 1.0, 1.0].pack('F*')
      GL.TexParameterfv(GL::TEXTURE_2D, GL::TEXTURE_BORDER_COLOR, border_color)
    end

    def attach_to_framebuffer
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::TEXTURE_2D, @depth_texture, 0)
      # No color buffer needed
      GL.DrawBuffer(GL::NONE)
      GL.ReadBuffer(GL::NONE)
    end

    def check_framebuffer_complete
      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Shadow map framebuffer not complete: #{status}"
      end
    end
  end
end
