# frozen_string_literal: true

module Engine::Components
  class UISpriteRenderer < Engine::Component
    attr_reader :v1, :v2, :v3, :v4, :material

    def ui_renderer?
      true
    end

    def initialize(tl, tr, br, bl, material)
      @v1 = tl
      @v2 = tr
      @v3 = br
      @v4 = bl
      @material = material
    end

    def start
      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
    end

    def update(delta_time)
      GL.BindVertexArray(@vao)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)

      set_material_per_frame_data

      GL.DrawElements(GL::TRIANGLES, 6, GL::UNSIGNED_INT, 0)

      GL.BindVertexArray(0)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    private

    def set_material_per_frame_data
      set_camera_matrix
      material.set_mat4("model", game_object.model_matrix)
      material.update_shader
    end

    def set_camera_matrix
      camera_matrix = Matrix[
        [2.0 / Engine::Window.framebuffer_width, 0, 0, 0],
        [0, 2.0 / Engine::Window.framebuffer_height, 0, 0],
        [0, 0, 1, 0],
        [-1, -1, 0, 1]
      ]
      material.set_mat4("camera", camera_matrix)
    end

    def setup_index_buffer
      indices = [
        0, 2, 1,
        2, 0, 3
      ]

      ebo_buf = ' ' * 4
      GL.GenBuffers(1, ebo_buf)
      @ebo = ebo_buf.unpack('L')[0]
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)
      GL.BufferData(
        GL::ELEMENT_ARRAY_BUFFER, 6 * Fiddle::SIZEOF_INT,
        indices.pack('I*'), GL::STATIC_DRAW
      )
    end

    def setup_vertex_attribute_buffer
      va0_buf = ' ' * 4
      GL.GenVertexArrays(1, va0_buf)
      @vao = va0_buf.unpack('L')[0]
      GL.BindVertexArray(@vao)
    end

    def setup_vertex_buffer
      vbo_buf = ' ' * 4
      GL.GenBuffers(1, vbo_buf)
      vbo = vbo_buf.unpack('L')[0]
      points = [
        v1[0], v1[1], 0, 0, 0,
        v2[0], v2[1], 0, 1, 0,
        v3[0], v3[1], 0, 1, 1,
        v4[0], v4[1], 0, 0, 1
      ]

      GL.BindBuffer(GL::ARRAY_BUFFER, vbo)
      GL.BufferData(
        GL::ARRAY_BUFFER, 4 * 5 * Fiddle::SIZEOF_FLOAT,
        points.pack('F*'), GL::STATIC_DRAW
      )

      GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
      GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
      GL.EnableVertexAttribArray(0)
      GL.EnableVertexAttribArray(1)
    end
  end
end
