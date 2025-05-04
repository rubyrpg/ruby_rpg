module Engine
  class ComputeShader
    def initialize(compute_shader)
      @uniform_locations = {}
      @compute_shader = compile_shader(compute_shader)
      @program = GL.CreateProgram
      GL.AttachShader(@program, @compute_shader)
      GL.LinkProgram(@program)

      linked_buf = ' ' * 4
      GL.GetProgramiv(@program, GL::LINK_STATUS, linked_buf)
      linked = linked_buf.unpack('L')[0]
      if linked == 0
        compile_log = ' ' * 1024
        GL.GetProgramInfoLog(@program, 1023, nil, compile_log)
        compute_log = ' ' * 1024
        GL.GetShaderInfoLog(@compute_shader, 1023, nil, compute_log)
        puts "Shader program failed to link"
        puts compile_log.strip
        puts compute_log.strip
      end
      @uniform_cache = {}
      @uniform_locations = {}
    end

    def compile_shader(shader)
      handle = GL.CreateShader(GL::COMPUTE_SHADER)
      path = File.expand_path(File.join(GAME_DIR, shader))
      s_srcs = [File.read(path)].pack('p')
      s_lens = [File.size(path)].pack('I')
      GL.ShaderSource(handle, 1, s_srcs, s_lens)
      GL.CompileShader(handle)
      handle
    end

    def dispatch(x, y, z, floats: {}, textures: [], ints: {}, vec3s: {}, vec4s: {}, mat4s: {})
      textures.each_with_index { |texture, slot| set_texture(slot, texture) }

      GL.UseProgram(@program)

      floats.each { |name, value| set_float(name, value) }
      ints.each { |name, value| set_int(name, value) }
      vec3s.each { |name, value| set_vec3(name, value) }
      vec4s.each { |name, value| set_vec4(name, value) }
      mat4s.each { |name, value| set_mat4(name, value) }

      GL.DispatchCompute(x, y, z)
      GL.MemoryBarrier(GL::SHADER_IMAGE_ACCESS_BARRIER_BIT)
    end

    private

    def set_float(name, float)
      GL.Uniform1f(uniform_location(name), float)
    end

    def set_texture(slot, texture)
      #puts "set #{slot}, to #{texture}"
      GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
      if texture
        GL.BindImageTexture(slot, texture, 0, GL::FALSE, 0, GL::READ_WRITE, GL::RGBA32F)
      else
        GL.BindImageTexture(slot, 0, 0, GL::FALSE, 0, GL::READ_WRITE, GL::RGBA32F)
      end
    end

    def set_vec3(name, vec)
      GL.Uniform3f(uniform_location(name), vector[0], vector[1], vector[2])
    end

    def set_vec4(name, vec)
      GL.Uniform4f(uniform_location(name), vec[0], vec[1], vec[2], vec[3])
    end

    def set_mat4(name, mat)
      mat_array = [
        mat[0, 0], mat[0, 1], mat[0, 2], mat[0, 3],
        mat[1, 0], mat[1, 1], mat[1, 2], mat[1, 3],
        mat[2, 0], mat[2, 1], mat[2, 2], mat[2, 3],
        mat[3, 0], mat[3, 1], mat[3, 2], mat[3, 3]
      ]
      GL.UniformMatrix4fv(uniform_location(name), 1, GL::FALSE, mat_array.pack('F*'))
    end

    def set_int(name, int)
      GL.Uniform1i(uniform_location(name), int)
    end

    def uniform_location(name)
      @uniform_locations[name] ||= GL.GetUniformLocation(@program, name)
    end
  end
end
