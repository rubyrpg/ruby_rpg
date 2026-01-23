# frozen_string_literal: true

module Rendering
  class SkyboxCubemap
    CUBEMAP_SIZE = 512

    def initialize
      @rendered = false
      @ground_color = nil
      @horizon_color = nil
      @sky_color = nil
      @ground_y = nil
      @horizon_y = nil
      @sky_y = nil
      create_cubemap_texture
      create_framebuffer
    end

    def render_if_needed(ground_color, horizon_color, sky_color, ground_y, horizon_y, sky_y)
      return if @rendered &&
                @ground_color == ground_color &&
                @horizon_color == horizon_color &&
                @sky_color == sky_color &&
                @ground_y == ground_y &&
                @horizon_y == horizon_y &&
                @sky_y == sky_y

      @ground_color = ground_color
      @horizon_color = horizon_color
      @sky_color = sky_color
      @ground_y = ground_y
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
      Engine::GL.GenTextures(1, tex_buf)
      @cubemap_texture = tex_buf.unpack1('L')

      Engine::GL.BindTexture(Engine::GL::TEXTURE_CUBE_MAP, @cubemap_texture)

      6.times do |i|
        Engine::GL.TexImage2D(
          Engine::GL::TEXTURE_CUBE_MAP_POSITIVE_X + i,
          0,
          Engine::GL::RGBA16F,
          CUBEMAP_SIZE,
          CUBEMAP_SIZE,
          0,
          Engine::GL::RGBA,
          Engine::GL::FLOAT,
          nil
        )
      end

      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP, Engine::GL::TEXTURE_WRAP_S, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP, Engine::GL::TEXTURE_WRAP_T, Engine::GL::CLAMP_TO_EDGE)
      Engine::GL.TexParameteri(Engine::GL::TEXTURE_CUBE_MAP, Engine::GL::TEXTURE_WRAP_R, Engine::GL::CLAMP_TO_EDGE)

      Engine::GL.BindTexture(Engine::GL::TEXTURE_CUBE_MAP, 0)
    end

    def create_framebuffer
      fbo_buf = ' ' * 4
      Engine::GL.GenFramebuffers(1, fbo_buf)
      @fbo = fbo_buf.unpack1('L')
    end

    def render_all_faces
      Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, @fbo)
      Engine::GL.Viewport(0, 0, CUBEMAP_SIZE, CUBEMAP_SIZE)

      shader.use
      shader.set_vec3("groundColour", @ground_color) if @ground_color
      shader.set_vec3("horizonColour", @horizon_color) if @horizon_color
      shader.set_vec3("skyColour", @sky_color) if @sky_color
      shader.set_float("groundY", @ground_y) if @ground_y
      shader.set_float("horizonY", @horizon_y) if @horizon_y
      shader.set_float("skyY", @sky_y) if @sky_y

      6.times do |face_index|
        Engine::GL.FramebufferTexture2D(
          Engine::GL::FRAMEBUFFER,
          Engine::GL::COLOR_ATTACHMENT0,
          Engine::GL::TEXTURE_CUBE_MAP_POSITIVE_X + face_index,
          @cubemap_texture,
          0
        )

        Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)
        shader.set_int("faceIndex", face_index)
        screen_quad.draw_raw
      end
    end

    def shader
      @shader ||= Engine::Shader.skybox_cubemap
    end

    def screen_quad
      @screen_quad ||= ScreenQuad.new
    end
  end
end
