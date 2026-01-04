# frozen_string_literal: true

module Rendering
  class ScreenQuad
    def initialize
      setup_vao
      setup_vbo
      GL.BindVertexArray(0)
    end

    def draw(material, texture)
      material.set_runtime_texture("screenTexture", texture)
      draw_with_material(material)
    end

    def draw_with_material(material)
      material.update_shader
      GL.BindVertexArray(@vao)
      GL.DrawArrays(GL::TRIANGLES, 0, 6)
      GL.BindVertexArray(0)
    end

    def draw_raw
      GL.BindVertexArray(@vao)
      GL.DrawArrays(GL::TRIANGLES, 0, 6)
      GL.BindVertexArray(0)
    end

    private

    def setup_vao
      vao_buf = ' ' * 4
      GL.GenVertexArrays(1, vao_buf)
      @vao = vao_buf.unpack1('L')
      GL.BindVertexArray(@vao)
    end

    def setup_vbo
      # Fullscreen quad: 2 triangles covering -1 to 1 in NDC
      # Each vertex: x, y, u, v
      vertices = [
        # First triangle
        -1.0,  1.0,  0.0, 1.0,
        -1.0, -1.0,  0.0, 0.0,
         1.0, -1.0,  1.0, 0.0,
        # Second triangle
        -1.0,  1.0,  0.0, 1.0,
         1.0, -1.0,  1.0, 0.0,
         1.0,  1.0,  1.0, 1.0
      ]

      vbo_buf = ' ' * 4
      GL.GenBuffers(1, vbo_buf)
      vbo = vbo_buf.unpack1('L')

      GL.BindBuffer(GL::ARRAY_BUFFER, vbo)
      GL.BufferData(GL::ARRAY_BUFFER, vertices.length * Fiddle::SIZEOF_FLOAT, vertices.pack('F*'), GL::STATIC_DRAW)

      stride = 4 * Fiddle::SIZEOF_FLOAT
      GL.VertexAttribPointer(0, 2, GL::FLOAT, GL::FALSE, stride, 0)
      GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, stride, 2 * Fiddle::SIZEOF_FLOAT)
      GL.EnableVertexAttribArray(0)
      GL.EnableVertexAttribArray(1)
    end
  end
end
