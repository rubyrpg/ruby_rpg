# frozen_string_literal: true

module Engine
  module OpenGL
    class ComputeShader
      def initialize(shader_path)
        @uniform_locations = {}
        @compute_shader = compile_shader(shader_path)
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
          raise "Shader program failed to link:\n#{compile_log.strip}\n#{compute_log.strip}"
        end
        @uniform_cache = {}
        @uniform_locations = {}
      end

      def dispatch(width, height, depth, textures: [], floats: {}, ints: {})
        # Extract gl_texture from ComputeTexture objects
        textures.each_with_index do |texture, slot|
          gl_tex = texture.respond_to?(:gl_texture) ? texture.gl_texture : texture
          set_texture(slot, gl_tex)
        end

        GL.UseProgram(@program)

        floats.each { |name, value| set_float(name, value) }
        ints.each { |name, value| set_int(name, value) }

        GL.DispatchCompute(width, height, depth)
        GL.MemoryBarrier(GL::SHADER_IMAGE_ACCESS_BARRIER_BIT)
      end

      private

      def compile_shader(shader_path)
        handle = GL.CreateShader(GL::COMPUTE_SHADER)
        path = File.expand_path(File.join(GAME_DIR, shader_path))
        s_srcs = [File.read(path)].pack('p')
        s_lens = [File.size(path)].pack('I')
        GL.ShaderSource(handle, 1, s_srcs, s_lens)
        GL.CompileShader(handle)
        handle
      end

      def set_float(name, float)
        GL.Uniform1f(uniform_location(name), float)
      end

      def set_texture(slot, texture)
        GL.ActiveTexture(Object.const_get("GL::TEXTURE#{slot}"))
        if texture
          GL.BindImageTexture(slot, texture, 0, GL::FALSE, 0, GL::READ_WRITE, GL::RGBA32F)
        else
          GL.BindImageTexture(slot, 0, 0, GL::FALSE, 0, GL::READ_WRITE, GL::RGBA32F)
        end
      end

      def set_int(name, int)
        GL.Uniform1i(uniform_location(name), int)
      end

      def uniform_location(name)
        @uniform_locations[name] ||= GL.GetUniformLocation(@program, name)
      end
    end
  end
end
