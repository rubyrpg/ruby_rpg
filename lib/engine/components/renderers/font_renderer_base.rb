# frozen_string_literal: true

module Engine::Components
  class FontRendererBase < Engine::Component
    serialize :font, :string

    attr_reader :mesh, :texture

    def awake
      # Original vertex order for ear-clipping, UVs flipped for Y-down camera
      @mesh = Engine::PolygonMesh.new(
        [Vector[-0.5, 0.5], Vector[0.5, 0.5], Vector[0.5, -0.5], Vector[-0.5, -0.5]],
        [[0, 1], [1, 1], [1, 0], [0, 0]]
      )
      @texture = @font.texture.texture
    end

    def start
      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
      Engine::GL.BindVertexArray(0)
    end

    def update_string(string)
      @string = string
      update_vbo_buf
    end

    def draw
      shader.use
      Engine::GL.BindVertexArray(@vao)
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)

      set_shader_per_frame_data

      Engine::GL.DrawElementsInstanced(Engine::GL::TRIANGLES, mesh.index_data.length, Engine::GL::UNSIGNED_INT, 0, @string.length)
    end

    private

    def shader
      raise NotImplementedError, "Subclasses must implement #shader"
    end

    def set_shader_camera_matrix
      raise NotImplementedError, "Subclasses must implement #set_shader_camera_matrix"
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
      Engine::Material.bind_texture(0, Engine::GL::TEXTURE_2D, texture)
      shader.set_int("fontTexture", 0)
    end

    def setup_index_buffer
      indices = mesh.index_data

      ebo_buf = ' ' * 4
      Engine::GL.GenBuffers(1, ebo_buf)
      @ebo = ebo_buf.unpack('L')[0]
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)
      Engine::GL.BufferData(
        Engine::GL::ELEMENT_ARRAY_BUFFER, indices.length * Fiddle::SIZEOF_INT,
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
      vbo = vbo_buf.unpack('L')[0]
      points = mesh.vertex_data

      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, vbo)
      Engine::GL.BufferData(
        Engine::GL::ARRAY_BUFFER, @mesh.vertex_data.length * Fiddle::SIZEOF_FLOAT,
        points.pack('F*'), Engine::GL::STATIC_DRAW
      )

      Engine::GL.VertexAttribPointer(0, 3, Engine::GL::FLOAT, Engine::GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
      Engine::GL.VertexAttribPointer(1, 2, Engine::GL::FLOAT, Engine::GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.EnableVertexAttribArray(0)
      Engine::GL.EnableVertexAttribArray(1)

      generate_instance_vbo_buf
    end

    def generate_instance_vbo_buf
      @instance_vbo = set_instance_vbo_buf
      update_vbo_buf
    end

    def set_instance_vbo_buf
      instance_vbo_buf = ' ' * 4
      Engine::GL.GenBuffers(1, instance_vbo_buf)
      instance_vbo_buf.unpack('L')[0]
    end

    def update_vbo_buf
      vertex_data = @font.vertex_data(@string)
      string_length = @string.chars.reject { |c| c == "\n" }.length

      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)
      vertex_size = Fiddle::SIZEOF_INT + (Fiddle::SIZEOF_FLOAT * 2)
      Engine::GL.BufferData(
        Engine::GL::ARRAY_BUFFER, string_length * vertex_size,
        vertex_data.pack('IFF' * string_length), Engine::GL::STATIC_DRAW
      )
      Engine::GL.VertexAttribIPointer(2, 1, Engine::GL::INT, vertex_size, 0)
      Engine::GL.VertexAttribPointer(3, 2, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_size, Fiddle::SIZEOF_INT)
      Engine::GL.EnableVertexAttribArray(2)
      Engine::GL.EnableVertexAttribArray(3)
      Engine::GL.VertexAttribDivisor(2, 1)
      Engine::GL.VertexAttribDivisor(3, 1)
    end
  end
end
