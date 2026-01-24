# frozen_string_literal: true

module Rendering
  class ScreenQuad
    def initialize
      setup_vao
      setup_vbo
      Engine::GL.BindVertexArray(0)
    end

    def draw(material, texture)
      material.set_runtime_texture("screenTexture", texture)
      draw_with_material(material)
    end

    def draw_with_material(material)
      material.update_shader
      Engine::GL.BindVertexArray(@vao)
      Engine::GL.DrawArrays(Engine::GL::TRIANGLES, 0, 6)
    end

    def draw_raw
      Engine::GL.BindVertexArray(@vao)
      Engine::GL.DrawArrays(Engine::GL::TRIANGLES, 0, 6)
    end

    private

    def setup_vao
      vao_buf = ' ' * 4
      Engine::GL.GenVertexArrays(1, vao_buf)
      @vao = vao_buf.unpack1('L')
      Engine::GL.BindVertexArray(@vao)
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
      Engine::GL.GenBuffers(1, vbo_buf)
      vbo = vbo_buf.unpack1('L')

      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, vbo)
      Engine::GL.BufferData(Engine::GL::ARRAY_BUFFER, vertices.length * Fiddle::SIZEOF_FLOAT, vertices.pack('F*'), Engine::GL::STATIC_DRAW)

      stride = 4 * Fiddle::SIZEOF_FLOAT
      Engine::GL.VertexAttribPointer(0, 2, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 0)
      Engine::GL.VertexAttribPointer(1, 2, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 2 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.EnableVertexAttribArray(0)
      Engine::GL.EnableVertexAttribArray(1)
    end
  end
end
