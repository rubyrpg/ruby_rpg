# frozen_string_literal: true

module Rendering
  module DebugDraw
    SCALE_FACTOR = 3 # Render at 1/3 resolution for thicker lines

    class << self
      def draw(target_framebuffer)
        lines = Engine::Debug.lines
        return if lines.empty?

        update_render_texture_size

        # Draw lines to low-res texture
        render_texture.bind
        Engine::GL.ClearColor(0.0, 0.0, 0.0, 0.0)
        Engine::GL.Clear(Engine::GL::COLOR_BUFFER_BIT)
        Engine::GL.Disable(Engine::GL::DEPTH_TEST)

        line_shader.use
        line_shader.set_mat4('camera', camera_matrix)

        update_vertex_data(lines)
        draw_lines(lines.size * 2)

        # Composite onto main framebuffer
        Engine::GL.BindFramebuffer(Engine::GL::FRAMEBUFFER, target_framebuffer)
        Engine::GL.Viewport(0, 0, Engine::Window.framebuffer_width, Engine::Window.framebuffer_height)
        Engine::GL.Enable(Engine::GL::BLEND)

        composite_material.set_runtime_texture('debugTexture', render_texture.color_texture)
        composite_material.set_vec2('texelSize', [1.0 / render_texture.width, 1.0 / render_texture.height])
        screen_quad.draw_with_material(composite_material)

        Engine::Debug.clear
      end

      private

      def update_render_texture_size
        width = Engine::Window.framebuffer_width / SCALE_FACTOR
        height = Engine::Window.framebuffer_height / SCALE_FACTOR
        width = [width, 1].max
        height = [height, 1].max

        if @render_texture.nil?
          @render_texture = RenderTexture.new(width, height)
        else
          @render_texture.resize(width, height)
        end
      end

      def render_texture
        @render_texture
      end

      def update_vertex_data(lines)
        vertex_data = []

        lines.each do |line|
          vertex_data << line[:from][0] << line[:from][1] << line[:from][2]
          vertex_data << line[:color][0] << line[:color][1] << line[:color][2]

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

      def line_shader
        @line_shader ||= Engine::Shader.for('debug_line_vertex.glsl', 'debug_line_frag.glsl', source: :engine)
      end

      def composite_shader
        @composite_shader ||= Engine::Shader.for('fullscreen_vertex.glsl', 'debug_composite_frag.glsl', source: :engine)
      end

      def composite_material
        @composite_material ||= Engine::Material.create(shader: composite_shader)
      end

      def screen_quad
        @screen_quad ||= ScreenQuad.new
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

        stride = 6 * 4

        Engine::GL.VertexAttribPointer(0, 3, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 0)
        Engine::GL.EnableVertexAttribArray(0)

        Engine::GL.VertexAttribPointer(1, 3, Engine::GL::FLOAT, Engine::GL::FALSE, stride, 3 * 4)
        Engine::GL.EnableVertexAttribArray(1)

        Engine::GL.BindVertexArray(0)
      end
    end
  end
end
