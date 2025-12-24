# frozen_string_literal: true

module Rendering
  class CubemapShadowMap
    # OpenGL cubemap face targets in order: +X, -X, +Y, -Y, +Z, -Z
    CUBE_MAP_FACES = [
      GL::TEXTURE_CUBE_MAP_POSITIVE_X,
      GL::TEXTURE_CUBE_MAP_NEGATIVE_X,
      GL::TEXTURE_CUBE_MAP_POSITIVE_Y,
      GL::TEXTURE_CUBE_MAP_NEGATIVE_Y,
      GL::TEXTURE_CUBE_MAP_POSITIVE_Z,
      GL::TEXTURE_CUBE_MAP_NEGATIVE_Z
    ].freeze

    attr_reader :size, :framebuffer, :depth_texture

    def initialize(size = 1024)
      @size = size
      create_framebuffer
      create_depth_cubemap
      check_framebuffer_complete
      unbind
    end

    def bind_face(face_index)
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      GL.FramebufferTexture2D(
        GL::FRAMEBUFFER,
        GL::DEPTH_ATTACHMENT,
        CUBE_MAP_FACES[face_index],
        @depth_texture,
        0
      )
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

    def create_depth_cubemap
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @depth_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_CUBE_MAP, @depth_texture)

      # Allocate storage for each cubemap face
      CUBE_MAP_FACES.each do |face|
        GL.TexImage2D(face, 0, GL::DEPTH_COMPONENT32F, @size, @size, 0, GL::DEPTH_COMPONENT, GL::FLOAT, nil)
      end

      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_MIN_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_MAG_FILTER, GL::NEAREST)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_R, GL::CLAMP_TO_EDGE)

      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      # Attach first face initially for completeness check
      GL.FramebufferTexture2D(GL::FRAMEBUFFER, GL::DEPTH_ATTACHMENT, GL::TEXTURE_CUBE_MAP_POSITIVE_X, @depth_texture, 0)
      GL.DrawBuffer(GL::NONE)
      GL.ReadBuffer(GL::NONE)
    end

    def check_framebuffer_complete
      GL.BindFramebuffer(GL::FRAMEBUFFER, @framebuffer)
      status = GL.CheckFramebufferStatus(GL::FRAMEBUFFER)
      unless status == GL::FRAMEBUFFER_COMPLETE
        raise "Cubemap shadow map framebuffer not complete: #{status}"
      end
    end
  end
end
