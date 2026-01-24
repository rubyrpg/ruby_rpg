# frozen_string_literal: true

module Engine
  module OpenGL
    class ComputeShader
      def initialize(shader_path)
        @uniform_locations = {}
        @compute_shader = compile_shader(shader_path)
        @program = Engine::GL.CreateProgram
        Engine::GL.AttachShader(@program, @compute_shader)
        Engine::GL.LinkProgram(@program)

        linked_buf = ' ' * 4
        Engine::GL.GetProgramiv(@program, Engine::GL::LINK_STATUS, linked_buf)
        linked = linked_buf.unpack('L')[0]
        if linked == 0
          compile_log = ' ' * 1024
          Engine::GL.GetProgramInfoLog(@program, 1023, nil, compile_log)
          compute_log = ' ' * 1024
          Engine::GL.GetShaderInfoLog(@compute_shader, 1023, nil, compute_log)
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

        Engine::GL.UseProgram(@program)

        floats.each { |name, value| set_float(name, value) }
        ints.each { |name, value| set_int(name, value) }

        Engine::GL.DispatchCompute(width, height, depth)
        Engine::GL.MemoryBarrier(Engine::GL::SHADER_IMAGE_ACCESS_BARRIER_BIT)
      end

      private

      def compile_shader(shader_path)
        handle = Engine::GL.CreateShader(Engine::GL::COMPUTE_SHADER)
        path = File.expand_path(File.join(GAME_DIR, shader_path))
        s_srcs = [File.read(path)].pack('p')
        s_lens = [File.size(path)].pack('I')
        Engine::GL.ShaderSource(handle, 1, s_srcs, s_lens)
        Engine::GL.CompileShader(handle)
        handle
      end

      def set_float(name, float)
        Engine::GL.Uniform1f(uniform_location(name), float)
      end

      def set_texture(slot, texture)
        Engine::GL.ActiveTexture(Object.const_get("Engine::GL::TEXTURE#{slot}"))
        if texture
          Engine::GL.BindImageTexture(slot, texture, 0, Engine::GL::FALSE, 0, Engine::GL::READ_WRITE, Engine::GL::RGBA32F)
        else
          Engine::GL.BindImageTexture(slot, 0, 0, Engine::GL::FALSE, 0, Engine::GL::READ_WRITE, Engine::GL::RGBA32F)
        end
      end

      def set_int(name, int)
        Engine::GL.Uniform1i(uniform_location(name), int)
      end

      def uniform_location(name)
        @uniform_locations[name] ||= Engine::GL.GetUniformLocation(@program, name)
      end
    end
  end
end
