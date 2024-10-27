module Engine
  class Shader
    def initialize(vertex_shader, fragment_shader)
      @vertex_shader = compile_shader(vertex_shader, GL::VERTEX_SHADER)
      @fragment_shader = compile_shader(fragment_shader, GL::FRAGMENT_SHADER)
      @program = GL.CreateProgram
      GL.AttachShader(@program, @vertex_shader)
      GL.AttachShader(@program, @fragment_shader)
      GL.LinkProgram(@program)

      linked_buf = ' ' * 4
      GL.GetProgramiv(@program, GL::LINK_STATUS, linked_buf)
      linked = linked_buf.unpack('L')[0]
      if linked == 0
        compile_log = ' ' * 1024
        GL.GetProgramInfoLog(@program, 1023, nil, compile_log)
        vertex_log = ' ' * 1024
        GL.GetShaderInfoLog(@vertex_shader, 1023, nil, vertex_log)
        fragment_log = ' ' * 1024
        GL.GetShaderInfoLog(@fragment_shader, 1023, nil, fragment_log)
        puts "Shader program failed to link"
        puts compile_log.strip
        puts vertex_log.strip
        puts fragment_log.strip
      end
      @uniform_cache = {}
      @uniform_locations = {}
    end

    def compile_shader(shader, type)
      handle = GL.CreateShader(type)
      path = File.join(File.dirname(__FILE__), shader)
      s_srcs = [File.read(path)].pack('p')
      s_lens = [File.size(path)].pack('I')
      GL.ShaderSource(handle, 1, s_srcs, s_lens)
      GL.CompileShader(handle)
      handle
    end

    def use
      GL.UseProgram(@program)
    end

    def set_vec3(name, vec)
      return if @uniform_cache[name] == vec
      @uniform_cache[name] = vec
      vector = if vec.is_a?(Vector)
                 vec
               else
                 Vector[vec[:r], vec[:g], vec[:b]]
               end
      GL.Uniform3f(uniform_location(name), vector[0], vector[1], vector[2])
    end

    def set_vec4(name, vec)
      return if @uniform_cache[name] == vec
      @uniform_cache[name] = vec
      GL.Uniform4f(uniform_location(name), vec[0], vec[1], vec[2], vec[3])
    end

    def set_mat4(name, mat)
      return if @uniform_cache[name] == mat
      @uniform_cache[name] = mat
      mat_array = [
        mat[0, 0], mat[0, 1], mat[0, 2], mat[0, 3],
        mat[1, 0], mat[1, 1], mat[1, 2], mat[1, 3],
        mat[2, 0], mat[2, 1], mat[2, 2], mat[2, 3],
        mat[3, 0], mat[3, 1], mat[3, 2], mat[3, 3]
      ]
      GL.UniformMatrix4fv(uniform_location(name), 1, GL::FALSE, mat_array.pack('F*'))
    end

    def set_int(name, int)
      return if @uniform_cache[name] == int
      @uniform_cache[name] = int
      GL.Uniform1i(uniform_location(name), int)
    end

    def set_float(name, float)
      return if @uniform_cache[name] == float
      @uniform_cache[name] = float
      GL.Uniform1f(uniform_location(name), float)
    end

    private

    def uniform_location(name)
      @uniform_locations[name] ||= GL.GetUniformLocation(@program, name)
    end
  end
end
