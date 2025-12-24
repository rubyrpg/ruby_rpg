# frozen_string_literal: true

module Rendering
  class CubemapShadowMapArray
    attr_reader :size, :layer_count, :framebuffer, :depth_texture

    def initialize(size: 1024, layer_count: 4)
      @size = size
      @layer_count = layer_count
      create_framebuffer
      create_depth_cubemap_array
      check_framebuffer_complete
      unbind
    end

    def bind_face(layer_index, face_index)
      raise "Layer index #{layer_index} out of bounds" if layer_index >= @layer_count
      raise "Face index #{face_index} out of bounds" if face_index >= 6

      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      # In a cubemap array, layers are: layer0_face0, layer0_face1, ..., layer0_face5, layer1_face0, ...
      array_layer = layer_index * 6 + face_index
      GL.FramebufferTextureLayer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, @depth_texture, 0, array_layer)
      GL.Viewport(0, 0, @size, @size)
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

    def create_depth_cubemap_array
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_CUBE_MAP_ARRAY, @depth_texture)

      # For cubemap arrays, depth = layer_count * 6 (6 faces per cubemap)
      GL.TexImage3D(
        GL::TEXTURE_CUBE_MAP_ARRAY,
        0,
        GL::DEPTH_COMPONENT32F,
        @size,
        @size,
        @layer_count * 6,
        0,
        GL::DEPTH_COMPONENT,
        GL::FLOAT,
        nil
      )

      GL.TexParameteri(GL::TEXTURE_CUBE_MAP_ARRAY, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP_ARRAY, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP_ARRAY, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP_ARRAY, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP_ARRAY, GL::TEXTURE_WRAP_R, GL::CLAMP_TO_EDGE)

      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      # Attach first layer's first face for completeness check
      GL.FramebufferTextureLayer(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, @depth_texture, 0, 0)
      GL.DrawBuffer(GL::NONE)
      GL.ReadBuffer(GL::NONE)
    end

    def check_framebuffer_complete
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Cubemap shadow map array framebuffer not complete: #{status}"
      end
    end
  end
end
