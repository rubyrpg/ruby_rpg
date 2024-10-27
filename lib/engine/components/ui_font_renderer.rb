module Engine::Components
  class UIFontRenderer < Engine::Component
    attr_reader :mesh, :texture

    def ui_renderer?
      true
    end

    def initialize(font, string)
      @mesh = Engine::PolygonMesh.new([Vector[-0.5, 0.5], Vector[0.5, 0.5], Vector[0.5, -0.5], Vector[-0.5, -0.5]], [[0, 0], [1, 0], [1, 1], [0, 1]])
      @texture = font.texture.texture
      @string = string
      @font = font
    end

    def start
      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
    end

    def update_string(string)
      @string = string
      update_vbo_buf
    end

    def update(delta_time)
      shader.use
      GL.BindVertexArray(@vao)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)

      set_shader_per_frame_data

      GL.DrawElementsInstanced(GL::TRIANGLES, mesh.index_data.length, GL::UNSIGNED_INT, 0, @string.length)
      GL.BindVertexArray(0)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    private

    def shader
      @shader ||= Engine::Shader.new('./shaders/text_vertex.glsl', './shaders/text_frag.glsl')
    end

    def set_shader_per_frame_data
      set_shader_camera_matrix
      set_shader_model_matrix
      set_shader_texture
    end

    def set_shader_model_matrix
      shader.set_mat4("model", game_object.model_matrix)
    end

    def set_shader_texture
      GL.ActiveTexture(GL::TEXTURE0)
      GL.BindTexture(GL::TEXTURE_2D, texture)
      shader.set_int("fontTexture", 0)
    end

    def set_shader_camera_matrix
      camera_matrix = Matrix[
        [2.0 / Engine::Window.framebuffer_width, 0, 0, 0],
        [0, 2.0 / Engine::Window.framebuffer_height, 0, 0],
        [0, 0, 1, 0],
        [-1, -1, 0, 1]
      ]
      shader.set_mat4("camera", camera_matrix)
    end

    def setup_index_buffer
      indices = mesh.index_data

      ebo_buf = ' ' * 4
      GL.GenBuffers(1, ebo_buf)
      @ebo = ebo_buf.unpack('L')[0]
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)
      GL.BufferData(
        GL::ELEMENT_ARRAY_BUFFER, indices.length * Fiddle::SIZEOF_INT,
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
      vbo = vbo_buf.unpack('L')[0]
      points = mesh.vertex_data

      GL.BindBuffer(GL::ARRAY_BUFFER, vbo)
      GL.BufferData(
        GL::ARRAY_BUFFER, @mesh.vertex_data.length * Fiddle::SIZEOF_FLOAT,
        points.pack('F*'), GL::STATIC_DRAW
      )

      GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
      GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
      GL.EnableVertexAttribArray(0)
      GL.EnableVertexAttribArray(1)

      generate_instance_vbo_buf
    end

    def generate_instance_vbo_buf
      @instance_vbo = set_instance_vbo_buf
      update_vbo_buf
    end

    def set_instance_vbo_buf
      instance_vbo_buf = ' ' * 4
      GL.GenBuffers(1, instance_vbo_buf)
      instance_vbo_buf.unpack('L')[0]
    end

    def update_vbo_buf
      vertex_data = @font.vertex_data(@string)
      string_length = @string.chars.reject{|c| c == "\n"}.length

      GL.BindBuffer(GL::ARRAY_BUFFER, @instance_vbo)
      vertex_size = Fiddle::SIZEOF_INT + (Fiddle::SIZEOF_FLOAT * 2)
      GL.BufferData(
        GL::ARRAY_BUFFER, string_length * vertex_size,
        vertex_data.pack('IFF' * string_length), GL::STATIC_DRAW
      )
      GL.VertexAttribIPointer(2, 1, GL::INT, vertex_size, 0)
      GL.VertexAttribPointer(3, 2, GL::FLOAT, GL::FALSE, vertex_size, Fiddle::SIZEOF_INT)
      GL.EnableVertexAttribArray(2)
      GL.EnableVertexAttribArray(3)
      GL.VertexAttribDivisor(2, 1)
      GL.VertexAttribDivisor(3, 1)
    end
  end
end
