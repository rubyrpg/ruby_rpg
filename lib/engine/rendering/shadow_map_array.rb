# frozen_string_literal: true

module Rendering
  class ShadowMapArray
    attr_reader :width, :height, :layer_count, :framebuffer, :depth_texture

    def initialize(width: 2048, height: 2048, layer_count: 4)
      @width = width
      @height = height
      @layer_count = layer_count
      create_framebuffer
      create_depth_texture_array
      check_framebuffer_complete
      unbind
    end

    def bind_layer(layer_index)
      raise "Layer index #{layer_index} out of bounds (max: #{@layer_count - 1})" if layer_index >= @layer_count

      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.FramebufferTextureLayer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, @depth_texture, 0, layer_index)
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

    def create_depth_texture_array
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_2D_ARRAY, @depth_texture)
      GL.TexImage3D(
        GL::TEXTURE_2D_ARRAY,
        0,
        GL::DEPTH_COMPONENT32F,
        @width,
        @height,
        @layer_count,
        0,
        GL::DEPTH_COMPONENT,
        GL::FLOAT,
        nil
      )

      GL.TexParameteri(GL::TEXTURE_2D_ARRAY, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D_ARRAY, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_2D_ARRAY, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_BORDER)
      GL.TexParameteri(GL::TEXTURE_2D_ARRAY, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_BORDER)
      border_color = [1.0, 1.0, 1.0, 1.0].pack('F*')
      GL.TexParameterfv(GL::TEXTURE_2D_ARRAY, GL::TEXTURE_BORDER_COLOR, border_color)
    end

    def check_framebuffer_complete
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.FramebufferTextureLayer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, @depth_texture, 0, 0)
      GL.DrawBuffer(GL::NONE)
      GL.ReadBuffer(GL::NONE)

      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Shadow map array framebuffer not complete: #{status}"
      end
    end
  end
end
