# frozen_string_literal: true

module Engine
  module OpenGL
    class ComputeTexture
      attr_reader :width, :height, :gl_texture

      def initialize(width, height)
        @width = width
        @height = height
        create_texture
      end

      private

      def create_texture
        tex_buf = ' ' * 4
        Engine::GL.GenTextures(1, tex_buf)
        @gl_texture = tex_buf.unpack('L')[0]

        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, @gl_texture)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_S, Engine::GL::REPEAT)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_WRAP_T, Engine::GL::REPEAT)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MIN_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexParameteri(Engine::GL::TEXTURE_2D, Engine::GL::TEXTURE_MAG_FILTER, Engine::GL::LINEAR)
        Engine::GL.TexImage2D(Engine::GL::TEXTURE_2D, 0, Engine::GL::RGBA32F, @width, @height, 0, Engine::GL::RGBA, Engine::GL::FLOAT, nil)
        Engine::GL.BindTexture(Engine::GL::TEXTURE_2D, 0)
      end
    end
  end
end
