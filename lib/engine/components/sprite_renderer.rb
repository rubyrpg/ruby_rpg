# frozen_string_literal: true

module Engine::Components
  class SpriteRenderer < Engine::Component
    attr_reader :v1, :v2, :v3, :v4, :texture, :frame_coords, :frame_rate, :loop
    attr_accessor :colour

    def renderer?
      true
    end

    def initialize(tl, tr, br, bl, texture, frame_coords = nil, frame_rate = nil, loop = true, colour = { r: 1, g: 1, b: 1.0 })
      @v1 = tl
      @v2 = tr
      @v3 = br
      @v4 = bl
      @texture = texture
      @colour = colour
      @frame_coords = frame_coords || [{ tl: Vector[0, 0], width: 1, height: 1 }]
      @frame_rate = frame_rate || 1
      @loop = loop
    end

    def start
      @start_time = Time.now

      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
    end

    def update(delta_time)
      shader.use
      GL.BindVertexArray(@vao)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)

      set_shader_per_frame_data

      GL.DrawElements(GL::TRIANGLES, 6, GL::UNSIGNED_INT, 0)
      GL.BindVertexArray(0)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    private

    def shader
      @shader ||= Engine::Shader.new('./shaders/sprite_vertex.glsl', './shaders/sprite_frag.glsl')
    end

    def set_shader_per_frame_data
      set_shader_camera_matrix
      set_shader_model_matrix
      set_shader_texture
      set_shader_sprite_colour
      set_shader_frame_data
    end

    def set_shader_frame_data
      current_frame_index = (Time.now - @start_time) * @frame_rate
      current_frame_index = if @loop
                              current_frame_index.to_i % @frame_coords.length
                            else
                              [@frame_coords.length - 1, current_frame_index.to_i].min
                            end

      current_frame_coords =
        [
          @frame_coords[current_frame_index][:tl][0],
          @frame_coords[current_frame_index][:tl][1],
          @frame_coords[current_frame_index][:width],
          @frame_coords[current_frame_index][:height]
        ]
      shader.set_vec4("frameCoords", current_frame_coords)
    end

    def set_shader_sprite_colour
      shader.set_vec3("spriteColor", colour)
    end

    def set_shader_texture
      GL.ActiveTexture(GL::TEXTURE0)
      GL.BindTexture(GL::TEXTURE_2D, texture)
      shader.set_int("image", 0)
    end

    def set_shader_model_matrix
      shader.set_mat4("model", game_object.model_matrix)
    end

    def set_shader_camera_matrix
      camera_matrix = Engine::Camera.instance.matrix
      shader.set_mat4("camera", camera_matrix)
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
