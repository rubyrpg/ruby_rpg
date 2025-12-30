# frozen_string_literal: true

module Rendering
  class SkyboxCubemap
    CUBEMAP_SIZE = 512

    def initialize
      @rendered = false
      @horizon_color = nil
      @sky_color = nil
      @horizon_y = nil
      @sky_y = nil
      create_cubemap_texture
      create_framebuffer
    end

    def render_if_needed(horizon_color, sky_color, horizon_y, sky_y)
      return if @rendered && @horizon_color == horizon_color && @sky_color == sky_color && @horizon_y == horizon_y && @sky_y == sky_y

      @horizon_color = horizon_color
      @sky_color = sky_color
      @horizon_y = horizon_y
      @sky_y = sky_y
      render_all_faces
      @rendered = true
    end

    def invalidate
      @rendered = false
    end

    def texture
      @cubemap_texture
    end

    private

    def create_cubemap_texture
      tex_buf = ' ' * 4
      GL.GenTextures(1, tex_buf)
      @cubemap_texture = tex_buf.unpack1('L')

      GL.BindTexture(GL::TEXTURE_CUBE_MAP, @cubemap_texture)

      6.times do |i|
        GL.TexImage2D(
          GL::TEXTURE_CUBE_MAP_POSITIVE_X + i,
          0,
          GL::RGBA16F,
          CUBEMAP_SIZE,
          CUBEMAP_SIZE,
          0,
          GL::RGBA,
          GL::FLOAT,
          nil
        )
      end

      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_S, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_T, GL::CLAMP_TO_EDGE)
      GL.TexParameteri(GL::TEXTURE_CUBE_MAP, GL::TEXTURE_WRAP_R, GL::CLAMP_TO_EDGE)

      GL.BindTexture(GL::TEXTURE_CUBE_MAP, 0)
    end

    def create_framebuffer
      fbo_buf = ' ' * 4
      GL.GenFramebuffers(1, fbo_buf)
      @fbo = fbo_buf.unpack1('L')
    end

    def render_all_faces
      GL.BindFramebuffer(GL::FRAMEBUFFER, @fbo)
      GL.Viewport(0, 0, CUBEMAP_SIZE, CUBEMAP_SIZE)

      shader.use
      shader.set_vec3("horizonColour", @horizon_color) if @horizon_color
      shader.set_vec3("skyColour", @sky_color) if @sky_color
      shader.set_float("horizonY", @horizon_y) if @horizon_y
      shader.set_float("skyY", @sky_y) if @sky_y

      6.times do |face_index|
        GL.FramebufferTexture2D(
          GL::FRAMEBUFFER,
          GL::COLOR_ATTACHMENT0,
          GL::TEXTURE_CUBE_MAP_POSITIVE_X + face_index,
          @cubemap_texture,
          0
        )

        GL.Clear(GL::COLOR_BUFFER_BIT)
        shader.set_int("faceIndex", face_index)
        screen_quad.draw_raw
      end

      GL.BindFramebuffer(GL::FRAMEBUFFER, 0)
    end

    def shader
      @shader ||= Engine::Shader.skybox_cubemap
    end

    def screen_quad
      @screen_quad ||= ScreenQuad.new
    end
  end
end
