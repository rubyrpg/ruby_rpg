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
        GL.GenTextures(1, tex_buf)
        @gl_texture = tex_buf.unpack('L')[0]

        GL.BindTexture(GL::TEXTURE_2D, @gl_texture)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
        GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
        GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA32F, @width, @height, 0, GL::RGBA, GL::FLOAT, nil)
        GL.BindTexture(GL::TEXTURE_2D, 0)
      end
    end
  end
end
