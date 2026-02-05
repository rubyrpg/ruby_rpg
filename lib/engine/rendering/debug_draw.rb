# frozen_string_literal: true

module Rendering
  module DebugDraw
    class << self
      def draw
        lines = Engine::Debug.lines
        return if lines.empty?

        setup_gl_state
        shader.use
        shader.set_mat4('camera', camera_matrix)

        update_vertex_data(lines)
        draw_lines(lines.size * 2)

        Engine::Debug.clear
      end

      private

      def setup_gl_state
        Engine::GL.Disable(Engine::GL::DEPTH_TEST)
      end

      def update_vertex_data(lines)
        # Each line = 2 vertices, each vertex = 6 floats (xyz + rgb)
        vertex_data = []

        lines.each do |line|
          # Start vertex
          vertex_data << line[:from][0] << line[:from][1] << line[:from][2]
          vertex_data << line[:color][0] << line[:color][1] << line[:color][2]

          # End vertex
          vertex_data << line[:to][0] << line[:to][1] << line[:to][2]
          vertex_data << line[:color][0] << line[:color][1] << line[:color][2]
        end

        Engine::GL.BindVertexArray(vao)
        Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, vbo)

        data = vertex_data.pack('f*')
        Engine::GL.BufferData(Engine::GL::ARRAY_BUFFER, data.bytesize, data, Engine::GL::DYNAMIC_DRAW)
      end

      def draw_lines(vertex_count)
        Engine::GL.BindVertexArray(vao)
        Engine::GL.DrawArrays(Engine::GL::LINES, 0, vertex_count)
        Engine::GL.BindVertexArray(0)
      end

      def camera_matrix
        Engine::Camera.instance&.matrix || Matrix.identity(4)
      end

      def shader
        @shader ||= Engine::Shader.for('debug_line_vertex.glsl', 'debug_line_frag.glsl', source: :engine)
      end

      def vao
        setup_buffers unless @vao
        @vao
      end

      def vbo
        setup_buffers unless @vbo
        @vbo
      end

      def setup_buffers
        vao_buf = ' ' * 4
        Engine::GL.GenVertexArrays(1, vao_buf)
        @vao = vao_buf.unpack1('L')

        vbo_buf = ' ' * 4
        Engine::GL.GenBuffers(1, vbo_buf)
        @vbo = vbo_buf.unpack1('L')

        Engine::GL.BindVertexArray(@vao)
        Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @vbo)

        stride = 6 * 4 # 6 floats * 4 bytes

        # Position attribute (location 0)
        Engine::GL.VertexAttribPointer(0, 3, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 0)
        Engine::GL.EnableVertexAttribArray(0)

        # Color attribute (location 1)
        Engine::GL.VertexAttribPointer(1, 3, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 3 * 4)
        Engine::GL.EnableVertexAttribArray(1)

        Engine::GL.BindVertexArray(0)
      end
    end
  end
end
