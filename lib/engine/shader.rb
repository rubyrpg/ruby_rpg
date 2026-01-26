module Engine
  class Shader
    include Serializable

    attr_reader :source

    @cache = {}

    def self.for(vertex_path, fragment_path, source: :game)
      key = [vertex_path, fragment_path, source]
      @cache[key] ||= create(vertex_path: vertex_path, fragment_path: fragment_path, source: source)
    end

    def self.from_file(vertex_path, fragment_path, source: :game)
      self.for(vertex_path, fragment_path, source: source)
    end

    def self.from_serializable_data(data)
      self.for(data[:vertex_path], data[:fragment_path], source: (data[:source] || :game).to_sym)
    end

    def serializable_data
      { vertex_path: @vertex_path, fragment_path: @fragment_path, source: @source }
    end

    def self.default
      @default ||= Shader.for('mesh_vertex.glsl', 'mesh_frag.glsl', source: :engine)
    end

    def self.vertex_lit
      @vertex_lit ||= Engine::Shader.for('vertex_lit_vertex.glsl', 'vertex_lit_frag.glsl', source: :engine)
    end

    def self.skybox_cubemap
      @skybox_cubemap ||= Shader.for('fullscreen_vertex.glsl', 'skybox_cubemap_frag.glsl', source: :engine)
    end

    def self.sprite
      @sprite ||= Engine::Shader.for('sprite_vertex.glsl', 'sprite_frag.glsl', source: :engine)
    end

    def self.instanced_sprite
      @instanced_sprite ||= Engine::Shader.for('instanced_sprite_vertex.glsl', 'instanced_sprite_frag.glsl', source: :engine)
    end

    def self.text
      @text ||= Engine::Shader.for('text_vertex.glsl', 'text_frag.glsl', source: :engine)
    end

    def self.ui_text
      @ui_text ||= Engine::Shader.for('text_vertex.glsl', 'text_frag.glsl', source: :engine)
    end

    def self.ui_sprite
      @ui_sprite ||= Engine::Shader.for('ui_sprite_vertex.glsl', 'ui_sprite_frag.glsl', source: :engine)
    end

    def self.fullscreen
      @fullscreen ||= Engine::Shader.for('fullscreen_vertex.glsl', 'fullscreen_frag.glsl', source: :engine)
    end

    def self.colour
      @colour ||= Engine::Shader.for('colour_vertex.glsl', 'colour_frag.glsl', source: :engine)
    end

    def self.shadow
      @shadow ||= Engine::Shader.for('shadow_vertex.glsl', 'shadow_frag.glsl', source: :engine)
    end

    def self.point_shadow
      @point_shadow ||= Engine::Shader.for('point_shadow_vertex.glsl', 'point_shadow_frag.glsl', source: :engine)
    end

    def awake
      @texture_fallbacks = {}
      @cubemap_fallbacks = {}
      @vertex_shader = compile_shader(@vertex_path, Engine::GL::VERTEX_SHADER)
      @fragment_shader = compile_shader(@fragment_path, Engine::GL::FRAGMENT_SHADER)
      @program = Engine::GL.CreateProgram
      Engine::GL.AttachShader(@program, @vertex_shader)
      Engine::GL.AttachShader(@program, @fragment_shader)
      Engine::GL.LinkProgram(@program)

      linked_buf = ' ' * 4
      Engine::GL.GetProgramiv(@program, Engine::GL::LINK_STATUS, linked_buf)
      linked = linked_buf.unpack('L')[0]
      if linked == 0
        compile_log = ' ' * 1024
        Engine::GL.GetProgramInfoLog(@program, 1023, nil, compile_log)
        vertex_log = ' ' * 1024
        Engine::GL.GetShaderInfoLog(@vertex_shader, 1023, nil, vertex_log)
        fragment_log = ' ' * 1024
        Engine::GL.GetShaderInfoLog(@fragment_shader, 1023, nil, fragment_log)
        puts "Shader program failed to link"
        puts compile_log.strip
        puts vertex_log.strip
        puts fragment_log.strip
      end
      @uniform_cache = {}
      @uniform_locations = {}
    end

    def compile_shader(shader, type)
      handle = Engine::GL.CreateShader(type)
      path = resolve_shader_path(shader)
      source = preprocess_shader(path)
      parse_texture_fallbacks(source)
      s_srcs = [source].pack('p')
      s_lens = [source.bytesize].pack('I')
      Engine::GL.ShaderSource(handle, 1, s_srcs, s_lens)
      Engine::GL.CompileShader(handle)
      handle
    end

    def resolve_shader_path(shader)
      if @source == :engine
        File.join(ENGINE_DIR, "shaders", shader)
      else
        File.join(GAME_DIR, "shaders", shader)
      end
    end

    def texture_fallback(name)
      @texture_fallbacks[name] || :white
    end

    def expected_textures
      @texture_fallbacks.keys
    end

    def cubemap_fallback(name)
      @cubemap_fallbacks[name]
    end

    def preprocess_shader(path, included = [])
      return "" if included.include?(path)
      included << path

      source = File.read(path)
      dir = File.dirname(path)

      source.gsub(/#include\s+"([^"]+)"/) do
        include_path = File.join(dir, $1)
        preprocess_shader(include_path, included)
      end
    end

    def use
      Engine::GL.UseProgram(@program)
    end

    def set_vec2(name, vec)
      return if @uniform_cache[name] == vec
      @uniform_cache[name] = vec
      Engine::GL.Uniform2f(uniform_location(name), vec[0], vec[1])
    end

    def set_vec3(name, vec)
      vector = if vec.is_a?(Vector)
                 vec
               else
                 Vector[vec[:r], vec[:g], vec[:b]]
               end
      cache_key = [vector[0], vector[1], vector[2]]
      return if @uniform_cache[name] == cache_key
      @uniform_cache[name] = cache_key
      Engine::GL.Uniform3f(uniform_location(name), vector[0], vector[1], vector[2])
    end

    def set_vec4(name, vec)
      return if @uniform_cache[name] == vec
      @uniform_cache[name] = vec
      Engine::GL.Uniform4f(uniform_location(name), vec[0], vec[1], vec[2], vec[3])
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
      Engine::GL.UniformMatrix4fv(uniform_location(name), 1, Engine::GL::FALSE, mat_array.pack('F*'))
    end

    def set_int(name, int)
      return if @uniform_cache[name] == int
      @uniform_cache[name] = int
      Engine::GL.Uniform1i(uniform_location(name), int)
    end

    def set_float(name, float)
      return if @uniform_cache[name] == float
      @uniform_cache[name] = float
      Engine::GL.Uniform1f(uniform_location(name), float)
    end

    private

    def parse_texture_fallbacks(source)
      source.scan(/uniform\s+sampler2D\s+(\w+)\s*;.*\/\/\s*@fallback\s+(\w+)/) do |name, fallback|
        @texture_fallbacks[name] = fallback.to_sym
      end
      source.scan(/uniform\s+samplerCube\s+(\w+)\s*;.*\/\/\s*@fallback\s+(\w+)/) do |name, fallback|
        @cubemap_fallbacks[name] = fallback.to_sym
      end
    end

    def uniform_location(name)
      @uniform_locations[name] ||= Engine::GL.GetUniformLocation(@program, name)
    end
  end
end
