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
        @ui_rect = game_object.component(UI::Rect)
        raise "UI::SpriteRenderer requires a UI::Rect component on the same GameObject" unless @ui_rect

        setup_vertex_attribute_buffer
        setup_index_buffer
        setup_vertex_buffer
        Engine::GL.BindVertexArray(0)
      end

      def draw
        rect = @ui_rect.computed_rect

        Engine::GL.BindVertexArray(@vao)
        Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)

        update_vertex_buffer(rect)
        set_material_per_frame_data

        Engine::GL.DrawElements(Engine::GL::TRIANGLES, 6, Engine::GL::UNSIGNED_INT, 0)

        Engine::GL.BindVertexArray(0)
        Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, 0)
      end

      private

      def set_material_per_frame_data
        set_camera_matrix
        material.set_mat4("model", Matrix.identity(4))
        material.update_shader
      end

      def set_camera_matrix
        # Y-down coordinate system: (0,0) at top-left, Y increases downward
        camera_matrix = Matrix[
          [2.0 / Engine::Window.framebuffer_width, 0, 0, 0],
          [0, -2.0 / Engine::Window.framebuffer_height, 0, 0],
          [0, 0, 1, 0],
          [-1, 1, 0, 1]
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
        Engine::GL.GenBuffers(1, ebo_buf)
        @ebo = ebo_buf.unpack('L')[0]
        Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)
        Engine::GL.BufferData(
          Engine::GL::ELEMENT_ARRAY_BUFFER, 6 * Fiddle::SIZEOF_INT,
          indices.pack('I*'), Engine::GL::STATIC_DRAW
        )
      end

      def setup_vertex_attribute_buffer
        vao_buf = ' ' * 4
        Engine::GL.GenVertexArrays(1, vao_buf)
        @vao = vao_buf.unpack('L')[0]
        Engine::GL.BindVertexArray(@vao)
      end

      def setup_vertex_buffer
        vbo_buf = ' ' * 4
        Engine::GL.GenBuffers(1, vbo_buf)
        @vbo = vbo_buf.unpack('L')[0]

        Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @vbo)
        Engine::GL.BufferData(
          Engine::GL::ARRAY_BUFFER, 4 * 5 * Fiddle::SIZEOF_FLOAT,
          nil, Engine::GL::DYNAMIC_DRAW
        )

        Engine::GL.VertexAttribPointer(0, 3, Engine::GL::FLOAT, Engine::GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
        Engine::GL.VertexAttribPointer(1, 2, Engine::GL::FLOAT, Engine::GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
        Engine::GL.EnableVertexAttribArray(0)
        Engine::GL.EnableVertexAttribArray(1)
      end

      def update_vertex_buffer(rect)
        return if @cached_rect == rect
        @cached_rect = rect

        # UV V=1 at screen bottom, V=0 at screen top (matches PNG top-to-bottom storage)
        vertices = [
          rect.left,  rect.bottom, 0, 0, 1,  # bottom-left
          rect.right, rect.bottom, 0, 1, 1,  # bottom-right
          rect.right, rect.top,    0, 1, 0,  # top-right
          rect.left,  rect.top,    0, 0, 0   # top-left
        ]

        Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @vbo)
        Engine::GL.BufferSubData(
          Engine::GL::ARRAY_BUFFER, 0, vertices.length * Fiddle::SIZEOF_FLOAT,
          vertices.pack('F*')
        )
      end
    end
  end
end
