module Engine
  class Shader
    include Serializable

    @cache = {}

    def self.from_file(vertex_path, fragment_path)
      key = [vertex_path, fragment_path]
      @cache[key] ||= new(vertex_path, fragment_path)
    end

    def self.from_serializable_data(data)
      from_file(data[:vertex_path], data[:fragment_path])
    end

    def serializable_data
      { vertex_path: @vertex_path, fragment_path: @fragment_path }
    end

    def self.default
      @default ||= Shader.new('./shaders/mesh_vertex.glsl', './shaders/mesh_frag.glsl')
    end

    def self.vertex_lit
      @vertex_lit ||= Engine::Shader.new('./shaders/vertex_lit_vertex.glsl', './shaders/vertex_lit_frag.glsl')
    end

    def self.skybox_cubemap
      @skybox_cubemap ||= Shader.new('./shaders/fullscreen_vertex.glsl', './shaders/skybox_cubemap_frag.glsl')
    end

    def self.sprite
      @sprite ||= Engine::Shader.new('./shaders/sprite_vertex.glsl', './shaders/sprite_frag.glsl')
    end

    def self.instanced_sprite
      @instanced_sprite ||= Engine::Shader.new('./shaders/instanced_sprite_vertex.glsl', './shaders/instanced_sprite_frag.glsl')
    end

    def self.text
      @text ||= Engine::Shader.new('./shaders/text_vertex.glsl', './shaders/text_frag.glsl')
    end

    def self.ui_text
      @ui_text ||= Engine::Shader.new('./shaders/text_vertex.glsl', './shaders/text_frag.glsl')
    end

    def self.ui_sprite
      @ui_sprite ||= Engine::Shader.new('./shaders/ui_sprite_vertex.glsl', './shaders/ui_sprite_frag.glsl')
    end

    def self.fullscreen
      @fullscreen ||= Engine::Shader.new('./shaders/fullscreen_vertex.glsl', './shaders/fullscreen_frag.glsl')
    end

    def self.colour
      @colour ||= Engine::Shader.new('./shaders/colour_vertex.glsl', './shaders/colour_frag.glsl')
    end

    def self.shadow
      @shadow ||= Engine::Shader.new('./shaders/shadow_vertex.glsl', './shaders/shadow_frag.glsl')
    end

    def self.point_shadow
      @point_shadow ||= Engine::Shader.new('./shaders/point_shadow_vertex.glsl', './shaders/point_shadow_frag.glsl')
    end

    def initialize(vertex_shader, fragment_shader)
      @vertex_path = vertex_shader
      @fragment_path = fragment_shader
      @texture_fallbacks = {}
      @cubemap_fallbacks = {}
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
      source = preprocess_shader(path)
      parse_texture_fallbacks(source)
      s_srcs = [source].pack('p')
      s_lens = [source.bytesize].pack('I')
      GL.ShaderSource(handle, 1, s_srcs, s_lens)
      GL.CompileShader(handle)
      handle
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
      GL.UseProgram(@program)
    end

    def set_vec2(name, vec)
      return if @uniform_cache[name] == vec
      @uniform_cache[name] = vec
      GL.Uniform2f(uniform_location(name), vec[0], vec[1])
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

    def parse_texture_fallbacks(source)
      source.scan(/uniform\s+sampler2D\s+(\w+)\s*;.*\/\/\s*@fallback\s+(\w+)/) do |name, fallback|
        @texture_fallbacks[name] = fallback.to_sym
      end
      source.scan(/uniform\s+samplerCube\s+(\w+)\s*;.*\/\/\s*@fallback\s+(\w+)/) do |name, fallback|
        @cubemap_fallbacks[name] = fallback.to_sym
      end
    end

    def uniform_location(name)
      @uniform_locations[name] ||= GL.GetUniformLocation(@program, name)
    end
  end
end
