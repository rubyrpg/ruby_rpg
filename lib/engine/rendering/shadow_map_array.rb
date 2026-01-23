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
    end

    def bind_layer(layer_index)
      raise "Layer index #{layer_index} out of bounds (max: #{@layer_count - 1})" if layer_index >= @layer_count

      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      Engine::GL.FramebufferTextureLayer(Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_ATTACHMENT, @depth_texture, 0, layer_index)
      Engine::GL.Viewport(0, 0, @width, @height)
      Engine::GL.Clear(Engine::GL::DEPTH_BUFFER_BIT)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_depth_texture_array
      tex_buf = ' ' * 4
      Engine::GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_2D_ARRAY, @depth_texture)
      Engine::GL.TexImage3D(
        Engine::GL::TEXTURE_2D_ARRAY,
        0,
        Engine::GL::DEPTH_COMPONENT32F,
        @width,
        @height,
        @layer_count,
        0,
        Engine::GL::DEPTH_COMPONENT,
        Engine::GL::FLOAT,
        nil
      )

      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D_ARRAY, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D_ARRAY, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D_ARRAY, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_BORDER)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D_ARRAY, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_BORDER)
      border_color = [1.0, 1.0, 1.0, 1.0].pack('F*')
      Engine::GL.TexParameterfv(Engine::GL::TEXTURE_2D_ARRAY, Engine::GL::TEXTURE_BORDER_COLOR, border_color)
    end

    def check_framebuffer_complete
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      Engine::GL.FramebufferTextureLayer(Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_ATTACHMENT, @depth_texture, 0, 0)
      Engine::GL.DrawBuffer(Engine::GL::NONE)
      Engine::GL.ReadBuffer(Engine::GL::NONE)

      status = Engine::GL.CheckFramebufferStatus(Engine::GL::FRAMEBUFFER)
      unless status == Engine::GL::FRAMEBUFFER_COMPLETE
        raise "Shadow map array framebuffer not complete: #{status}"
      end
    end
  end
end
