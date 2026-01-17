# frozen_string_literal: true

module Engine::Components
  module UI
    class SpriteRenderer < Engine::Component
      serialize :material

      attr_reader :material

      def ui_renderer?
        true
      end

      def start
        @ui_rect = game_object.components.find { |c| c.is_a?(UI::Rect) }
        raise "UI::SpriteRenderer requires a UI::Rect component on the same GameObject" unless @ui_rect

        setup_vertex_attribute_buffer
        setup_index_buffer
        setup_vertex_buffer
        GL.BindVertexArray(0)
      end

      def draw
        rect = @ui_rect.computed_rect

        GL.BindVertexArray(@vao)
        GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)

        update_vertex_buffer(rect)
        set_material_per_frame_data

        GL.DrawElements(GL::TRIANGLES, 6, GL::UNSIGNED_INT, 0)

        GL.BindVertexArray(0)
        GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, 0)
      end

      private

      def set_material_per_frame_data
        set_camera_matrix
        material.set_mat4("model", Matrix.identity(4))
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
        # Counter-clockwise winding for front faces
        # v0=bottom-left, v1=bottom-right, v2=top-right, v3=top-left
        indices = [
          0, 1, 2,
          0, 2, 3
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
        vao_buf = ' ' * 4
        GL.GenVertexArrays(1, vao_buf)
        @vao = vao_buf.unpack('L')[0]
        GL.BindVertexArray(@vao)
      end

      def setup_vertex_buffer
        vbo_buf = ' ' * 4
        GL.GenBuffers(1, vbo_buf)
        @vbo = vbo_buf.unpack('L')[0]

        GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
        GL.BufferData(
          GL::ARRAY_BUFFER, 4 * 5 * Fiddle::SIZEOF_FLOAT,
          nil, GL::DYNAMIC_DRAW
        )

        GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
        GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
        GL.EnableVertexAttribArray(0)
        GL.EnableVertexAttribArray(1)
      end

      def update_vertex_buffer(rect)
        vertices = [
          rect.left,  rect.bottom, 0, 0, 1,  # bottom-left
          rect.right, rect.bottom, 0, 1, 1,  # bottom-right
          rect.right, rect.top,    0, 1, 0,  # top-right
          rect.left,  rect.top,    0, 0, 0   # top-left
        ]

        GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
        GL.BufferSubData(
          GL::ARRAY_BUFFER, 0, vertices.length * Fiddle::SIZEOF_FLOAT,
          vertices.pack('F*')
        )
      end
    end
  end
end
