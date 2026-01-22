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

      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      # In a cubemap array, layers are: layer0_face0, layer0_face1, ..., layer0_face5, layer1_face0, ...
      array_layer = layer_index * 6 + face_index
      Engine::GL.FramebufferTextureLayer(Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_ATTACHMENT, @depth_texture, 0, array_layer)
      Engine::GL.Viewport(0, 0, @size, @size)
      Engine::GL.Clear(Engine::GL::DEPTH_BUFFER_BIT)
    end

    def unbind
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, 0)
    end

    private

    def create_framebuffer
      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @framebuffer = fbo_buf.unpack1('L')
    end

    def create_depth_cubemap_array
      tex_buf = ' ' * 4
      Engine::GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, @depth_texture)

      # For cubemap arrays, depth = layer_count * 6 (6 faces per cubemap)
      Engine::GL.TexImage3D(
        Engine::GL::TEXTURE_CUBE_MAP_ARRAY,
        0,
        Engine::GL::DEPTH_COMPONENT32F,
        @size,
        @size,
        @layer_count * 6,
        0,
        Engine::GL::DEPTH_COMPONENT,
        Engine::GL::FLOAT,
        nil
      )

      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::NEAREST)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP_ARRAY, Engine::GL::TEXTURE_WRAP_R, Engine::GL::CLAMP_TO_EDGE)

      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      # Attach first layer's first face for completeness check
      Engine::GL.FramebufferTextureLayer(Engine::GL::FRAMEBUFFER, Engine::GL::DEPTH_ATTACHMENT, @depth_texture, 0, 0)
      Engine::GL.DrawBuffer(Engine::GL::NONE)
      Engine::GL.ReadBuffer(Engine::GL::NONE)
    end

    def check_framebuffer_complete
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @framebuffer)
      status = Engine::GL.CheckFramebufferStatus(Engine::GL::FRAMEBUFFER)
      unless status == Engine::GL::FRAMEBUFFER_COMPLETE
        raise "Cubemap shadow map array framebuffer not complete: #{status}"
      end
    end
  end
end
