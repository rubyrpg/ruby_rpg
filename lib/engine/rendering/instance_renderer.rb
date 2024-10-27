# frozen_string_literal: true

module Rendering
  class InstanceRenderer
    attr_reader :mesh, :material

    def initialize(mesh, material)
      @mesh = mesh
      @material = material
      @mesh_renderers = []
      @mesh_matrix_data = []

      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
      generate_instance_vbo_buf
    end

    def add_instance(mesh_renderer)
      @mesh_renderers << mesh_renderer
      @mesh_matrix_data += mesh_renderer.game_object.model_matrix.to_a.flatten
    end

    def remove_instance(mesh_renderer)
      index = @mesh_renderers.index(mesh_renderer)
      @mesh_renderers.delete_at(index)
      @mesh_matrix_data[index * 16, 16] = []
    end

    def update_instance(mesh_renderer)
      index = @mesh_renderers.index(mesh_renderer)
      @mesh_matrix_data[index * 16, 16] = mesh_renderer.game_object.model_matrix.to_a.flatten
    end

    def draw_all
      set_material_per_frame_data

      GL.BindVertexArray(@vao)
      update_vbo_buf
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, @ebo)
      GL.BindBuffer(GL::ARRAY_BUFFER, @instance_vbo)

      GL.DrawElementsInstanced(GL::TRIANGLES, mesh.index_data.length, GL::UNSIGNED_INT, 0, @mesh_renderers.count)
      GL.BindVertexArray(0)
      GL.BindBuffer(GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    private

    def set_material_per_frame_data
      material.set_mat4("camera", Engine::Camera.instance.matrix)
      material.set_vec3("cameraPos", Engine::Camera.instance.game_object.pos)

      update_light_data
      material.update_shader
    end

    def update_light_data
      Engine::Components::PointLight.point_lights.each_with_index do |light, i|
        material.set_float("pointLights[#{i}].sqrRange", light.range * light.range)
        material.set_vec3("pointLights[#{i}].position", light.game_object.pos)
        material.set_vec3("pointLights[#{i}].colour", light.colour)
      end
      Engine::Components::DirectionLight.direction_lights.each_with_index do |light, i|
        material.set_vec3("directionalLights[#{i}].direction", light.game_object.forward)
        material.set_vec3("directionalLights[#{i}].colour", light.colour)
      end
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
      vertex_data_size = 20 * Fiddle::SIZEOF_FLOAT

      GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 0)
      GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, vertex_data_size, 3 * Fiddle::SIZEOF_FLOAT)
      GL.VertexAttribPointer(2, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 5 * Fiddle::SIZEOF_FLOAT)
      GL.VertexAttribPointer(3, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 8 * Fiddle::SIZEOF_FLOAT)
      GL.VertexAttribPointer(4, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 11 * Fiddle::SIZEOF_FLOAT)
      GL.VertexAttribPointer(5, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 14 * Fiddle::SIZEOF_FLOAT)
      GL.VertexAttribPointer(6, 3, GL::FLOAT, GL::FALSE, vertex_data_size, 17 * Fiddle::SIZEOF_FLOAT)
      GL.EnableVertexAttribArray(0)
      GL.EnableVertexAttribArray(1)
      GL.EnableVertexAttribArray(2)
      GL.EnableVertexAttribArray(3)
      GL.EnableVertexAttribArray(4)
      GL.EnableVertexAttribArray(5)
      GL.EnableVertexAttribArray(6)
    end

    def generate_instance_vbo_buf
      instance_vbo_buf = ' ' * 4
      GL.GenBuffers(1, instance_vbo_buf)
      @instance_vbo = instance_vbo_buf.unpack('L')[0]
      update_vbo_buf
    end

    def update_vbo_buf
      vertex_data = @mesh_matrix_data

      GL.BindBuffer(GL::ARRAY_BUFFER, @instance_vbo)
      GL.BufferData(
        GL::ARRAY_BUFFER, vertex_data.length * Fiddle::SIZEOF_FLOAT,
        vertex_data.pack('F*'), GL::STATIC_DRAW
      )

      vec4_size = Fiddle::SIZEOF_FLOAT * 4

      GL.EnableVertexAttribArray(7)
      GL.EnableVertexAttribArray(8)
      GL.EnableVertexAttribArray(9)
      GL.EnableVertexAttribArray(10)

      GL.VertexAttribPointer(7, 4, GL::FLOAT, GL::FALSE, 4 * vec4_size, 0)
      GL.VertexAttribPointer(8, 4, GL::FLOAT, GL::FALSE, 4 * vec4_size, 1 * vec4_size)
      GL.VertexAttribPointer(9, 4, GL::FLOAT, GL::FALSE, 4 * vec4_size, 2 * vec4_size)
      GL.VertexAttribPointer(10, 4, GL::FLOAT, GL::FALSE, 4 * vec4_size, 3 * vec4_size)

      GL.VertexAttribDivisor(7, 1)
      GL.VertexAttribDivisor(8, 1)
      GL.VertexAttribDivisor(9, 1)
      GL.VertexAttribDivisor(10, 1)
    end
  end
end
