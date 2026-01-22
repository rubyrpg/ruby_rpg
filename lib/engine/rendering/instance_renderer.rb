# frozen_string_literal: true

module Rendering
  class InstanceRenderer
    attr_reader :mesh, :material

    FLOATS_PER_MATRIX = 16
    BYTES_PER_MATRIX = FLOATS_PER_MATRIX * Fiddle::SIZEOF_FLOAT

    def initialize(mesh, material)
      @mesh = mesh
      @material = material
      @mesh_renderers = []
      @packed_data = String.new(encoding: Encoding::BINARY)

      setup_vertex_attribute_buffer
      setup_vertex_buffer
      setup_index_buffer
      generate_instance_vbo_buf
      Engine::GL.BindVertexArray(0)
    end

    def add_instance(mesh_renderer)
      @mesh_renderers << mesh_renderer
      floats = mesh_renderer.game_object.model_matrix.to_a.flatten
      @packed_data << floats.pack('F*')
    end

    def remove_instance(mesh_renderer)
      index = @mesh_renderers.index(mesh_renderer)
      @mesh_renderers.delete_at(index)
      # Remove this instance's bytes from packed data
      byte_offset = index * BYTES_PER_MATRIX
      @packed_data[byte_offset, BYTES_PER_MATRIX] = ''
    end

    def update_instance(mesh_renderer)
      index = @mesh_renderers.index(mesh_renderer)
      floats = mesh_renderer.game_object.model_matrix.to_a.flatten
      byte_offset = index * BYTES_PER_MATRIX
      @packed_data[byte_offset, BYTES_PER_MATRIX] = floats.pack('F*')
    end

    def draw_all
      set_material_per_frame_data

      Engine::GL.BindVertexArray(@vao)
      update_vbo_buf
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)
      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)

      Engine::GL.DrawElementsInstanced(Engine::GL::TRIANGLES, mesh.index_data.length, Engine::GL::UNSIGNED_INT, 0, @mesh_renderers.count)
      Engine::GL.BindVertexArray(0)
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    def draw_depth_only(light_space_matrix)
      return if @mesh_renderers.empty?

      shadow_shader = Engine::Shader.shadow
      shadow_shader.use
      shadow_shader.set_mat4("lightSpaceMatrix", light_space_matrix)

      Engine::GL.BindVertexArray(@vao)
      update_vbo_buf
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)
      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)

      Engine::GL.DrawElementsInstanced(Engine::GL::TRIANGLES, mesh.index_data.length, Engine::GL::UNSIGNED_INT, 0, @mesh_renderers.count)
      Engine::GL.BindVertexArray(0)
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    def draw_point_light_depth(light_space_matrix, light_pos, far_plane)
      return if @mesh_renderers.empty?

      shader = Engine::Shader.point_shadow
      shader.use
      shader.set_mat4("lightSpaceMatrix", light_space_matrix)
      shader.set_vec3("lightPos", light_pos)
      shader.set_float("farPlane", far_plane)

      Engine::GL.BindVertexArray(@vao)
      update_vbo_buf
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, @ebo)
      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)

      Engine::GL.DrawElementsInstanced(Engine::GL::TRIANGLES, mesh.index_data.length, Engine::GL::UNSIGNED_INT, 0, @mesh_renderers.count)
      Engine::GL.BindVertexArray(0)
      Engine::GL.BindBuffer(Engine::GL::ELEMENT_ARRAY_BUFFER, 0)
    end

    private

    def set_material_per_frame_data
      material.set_mat4("camera", Engine::Camera.instance.matrix)
      material.set_vec3("cameraPos", Engine::Camera.instance.game_object.pos)
      material.set_cubemap("skybox", nil)

      update_light_data
      material.update_shader
    end

    def update_light_data
      Engine::Components::PointLight.point_lights.each_with_index do |light, i|
        break if i >= 16
        material.set_float("pointLights[#{i}].sqrRange", light.range * light.range)
        material.set_vec3("pointLights[#{i}].position", light.position)
        material.set_vec3("pointLights[#{i}].colour", light.colour)
        has_shadow = light.cast_shadows && !light.shadow_layer_index.nil?
        material.set_int("pointLights[#{i}].castsShadows", has_shadow ? 1 : 0)
        if has_shadow
          material.set_int("pointLights[#{i}].shadowLayerIndex", light.shadow_layer_index)
          material.set_float("pointLights[#{i}].shadowFar", light.shadow_far)
        end
      end
      # Set shared point shadow map cubemap array
      material.set_cubemap_array("pointShadowMaps", RenderPipeline.point_shadow_map_array.depth_texture)

      Engine::Components::DirectionLight.direction_lights.each_with_index do |light, i|
        break if i >= 4
        material.set_vec3("directionalLights[#{i}].direction", light.direction)
        material.set_vec3("directionalLights[#{i}].colour", light.colour)
        has_shadow = light.cast_shadows && !light.shadow_layer_index.nil?
        material.set_int("directionalLights[#{i}].castsShadows", has_shadow ? 1 : 0)

        if has_shadow
          material.set_mat4("directionalLights[#{i}].lightSpaceMatrix", light.light_space_matrix)
        end
      end
      # Set shared directional shadow map array
      material.set_texture_array("directionalShadowMaps", RenderPipeline.directional_shadow_map_array.depth_texture)

      Engine::Components::SpotLight.spot_lights.each_with_index do |light, i|
        break if i >= 8
        material.set_vec3("spotLights[#{i}].position", light.position)
        material.set_vec3("spotLights[#{i}].direction", light.direction)
        material.set_float("spotLights[#{i}].sqrRange", light.range * light.range)
        material.set_vec3("spotLights[#{i}].colour", light.colour)
        material.set_float("spotLights[#{i}].innerCutoff", light.inner_cutoff)
        material.set_float("spotLights[#{i}].outerCutoff", light.outer_cutoff)
        has_shadow = light.cast_shadows && !light.shadow_layer_index.nil?
        material.set_int("spotLights[#{i}].castsShadows", has_shadow ? 1 : 0)

        if has_shadow
          material.set_mat4("spotLights[#{i}].lightSpaceMatrix", light.light_space_matrix)
          material.set_float("spotLights[#{i}].shadowNear", light.shadow_near)
          material.set_float("spotLights[#{i}].shadowFar", light.shadow_far)
        end
      end
      # Set shared spot shadow map array
      material.set_texture_array("spotShadowMaps", RenderPipeline.spot_shadow_map_array.depth_texture)
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
      vertex_data_size = 20 * Fiddle::SIZEOF_FLOAT

      Engine::GL.VertexAttribPointer(0, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 0)
      Engine::GL.VertexAttribPointer(1, 2, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 3 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.VertexAttribPointer(2, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 5 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.VertexAttribPointer(3, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 8 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.VertexAttribPointer(4, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 11 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.VertexAttribPointer(5, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 14 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.VertexAttribPointer(6, 3, Engine::GL::FLOAT, Engine::GL::FALSE, vertex_data_size, 17 * Fiddle::SIZEOF_FLOAT)
      Engine::GL.EnableVertexAttribArray(0)
      Engine::GL.EnableVertexAttribArray(1)
      Engine::GL.EnableVertexAttribArray(2)
      Engine::GL.EnableVertexAttribArray(3)
      Engine::GL.EnableVertexAttribArray(4)
      Engine::GL.EnableVertexAttribArray(5)
      Engine::GL.EnableVertexAttribArray(6)
    end

    def generate_instance_vbo_buf
      instance_vbo_buf = ' ' * 4
      Engine::GL.GenBuffers(1, instance_vbo_buf)
      @instance_vbo = instance_vbo_buf.unpack('L')[0]

      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)

      # Set up vertex attributes once (stored in VAO)
      vec4_size = Fiddle::SIZEOF_FLOAT * 4

      Engine::GL.EnableVertexAttribArray(7)
      Engine::GL.EnableVertexAttribArray(8)
      Engine::GL.EnableVertexAttribArray(9)
      Engine::GL.EnableVertexAttribArray(10)

      Engine::GL.VertexAttribPointer(7, 4, Engine::GL::FLOAT, Engine::GL::FALSE, 4 * vec4_size, 0)
      Engine::GL.VertexAttribPointer(8, 4, Engine::GL::FLOAT, Engine::GL::FALSE, 4 * vec4_size, 1 * vec4_size)
      Engine::GL.VertexAttribPointer(9, 4, Engine::GL::FLOAT, Engine::GL::FALSE, 4 * vec4_size, 2 * vec4_size)
      Engine::GL.VertexAttribPointer(10, 4, Engine::GL::FLOAT, Engine::GL::FALSE, 4 * vec4_size, 3 * vec4_size)

      Engine::GL.VertexAttribDivisor(7, 1)
      Engine::GL.VertexAttribDivisor(8, 1)
      Engine::GL.VertexAttribDivisor(9, 1)
      Engine::GL.VertexAttribDivisor(10, 1)
    end

    def update_vbo_buf
      Engine::GL.BindBuffer(Engine::GL::ARRAY_BUFFER, @instance_vbo)
      Engine::GL.BufferData(
        Engine::GL::ARRAY_BUFFER, @packed_data.bytesize,
        @packed_data, Engine::GL::DYNAMIC_DRAW
      )
    end
  end
end
