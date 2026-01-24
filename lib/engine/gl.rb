module Engine
  module GL
    # Try to load native extension for hot path
    begin
      require_relative '../../ext/gl_native/gl_native'
      NATIVE_AVAILABLE = true
      puts "GLNative extension loaded - using native calls"
    rescue LoadError => e
      NATIVE_AVAILABLE = false
      puts "GLNative extension not available (#{e.message}) - using Fiddle"
    end

    # Cached methods - avoid redundant GL state changes

    def self.Enable(flag)
      return if enable_flag_cache[flag] == true

      enable_flag_cache[flag] = true
      NATIVE_AVAILABLE ? GLNative.enable(flag) : ::GL.Enable(flag)
    end

    def self.Disable(flag)
      return if enable_flag_cache[flag] == false

      enable_flag_cache[flag] = false
      NATIVE_AVAILABLE ? GLNative.disable(flag) : ::GL.Disable(flag)
    end

    def self.enable_flag_cache
      @enable_flag_cache ||= {}
    end

    def self.UseProgram(program)
      return if @current_program == program

      @current_program = program
      NATIVE_AVAILABLE ? GLNative.use_program(program) : ::GL.UseProgram(program)
    end

    def self.ActiveTexture(texture_unit)
      return if @current_texture_unit == texture_unit

      @current_texture_unit = texture_unit
      NATIVE_AVAILABLE ? GLNative.active_texture(texture_unit) : ::GL.ActiveTexture(texture_unit)
    end

    def self.BindTexture(target, texture_id)
      cache_key = [@current_texture_unit, target]
      return if bound_textures[cache_key] == texture_id

      bound_textures[cache_key] = texture_id
      NATIVE_AVAILABLE ? GLNative.bind_texture(target, texture_id) : ::GL.BindTexture(target, texture_id)
    end

    def self.bound_textures
      @bound_textures ||= {}
    end

    # Pass-through methods

    def self.AttachShader(program, shader)
      NATIVE_AVAILABLE ? GLNative.attach_shader(program, shader) : ::GL.AttachShader(program, shader)
    end

    def self.BeginQuery(target, id)
      NATIVE_AVAILABLE ? GLNative.begin_query(target, id) : ::GL.BeginQuery(target, id)
    end

    def self.BindBuffer(target, buffer)
      return if bound_buffers[target] == buffer

      bound_buffers[target] = buffer
      NATIVE_AVAILABLE ? GLNative.bind_buffer(target, buffer) : ::GL.BindBuffer(target, buffer)
    end

    def self.bound_buffers
      @bound_buffers ||= {}
    end

    def self.BindFramebuffer(target, framebuffer)
      NATIVE_AVAILABLE ? GLNative.bind_framebuffer(target, framebuffer) : ::GL.BindFramebuffer(target, framebuffer)
    end

    def self.BindImageTexture(unit, texture, level, layered, layer, access, format)
      NATIVE_AVAILABLE ? GLNative.bind_image_texture(unit, texture, level, layered, layer, access, format) : ::GL.BindImageTexture(unit, texture, level, layered, layer, access, format)
    end

    def self.BindVertexArray(array)
      return if @current_vertex_array == array

      @current_vertex_array = array
      NATIVE_AVAILABLE ? GLNative.bind_vertex_array(array) : ::GL.BindVertexArray(array)
    end

    def self.BlendFunc(sfactor, dfactor)
      NATIVE_AVAILABLE ? GLNative.blend_func(sfactor, dfactor) : ::GL.BlendFunc(sfactor, dfactor)
    end

    def self.BlitFramebuffer(src_x0, src_y0, src_x1, src_y1, dst_x0, dst_y0, dst_x1, dst_y1, mask, filter)
      NATIVE_AVAILABLE ? GLNative.blit_framebuffer(src_x0, src_y0, src_x1, src_y1, dst_x0, dst_y0, dst_x1, dst_y1, mask, filter) : ::GL.BlitFramebuffer(src_x0, src_y0, src_x1, src_y1, dst_x0, dst_y0, dst_x1, dst_y1, mask, filter)
    end

    def self.BufferData(target, size, data, usage)
      NATIVE_AVAILABLE ? GLNative.buffer_data(target, size, data, usage) : ::GL.BufferData(target, size, data, usage)
    end

    def self.BufferSubData(target, offset, size, data)
      NATIVE_AVAILABLE ? GLNative.buffer_sub_data(target, offset, size, data) : ::GL.BufferSubData(target, offset, size, data)
    end

    def self.CheckFramebufferStatus(target)
      NATIVE_AVAILABLE ? GLNative.check_framebuffer_status(target) : ::GL.CheckFramebufferStatus(target)
    end

    def self.Clear(mask)
      NATIVE_AVAILABLE ? GLNative.clear(mask) : ::GL.Clear(mask)
    end

    def self.ClearColor(red, green, blue, alpha)
      NATIVE_AVAILABLE ? GLNative.clear_color(red, green, blue, alpha) : ::GL.ClearColor(red, green, blue, alpha)
    end

    def self.ColorMask(red, green, blue, alpha)
      NATIVE_AVAILABLE ? GLNative.color_mask(red, green, blue, alpha) : ::GL.ColorMask(red, green, blue, alpha)
    end

    def self.CompileShader(shader)
      NATIVE_AVAILABLE ? GLNative.compile_shader(shader) : ::GL.CompileShader(shader)
    end

    def self.CreateProgram
      NATIVE_AVAILABLE ? GLNative.create_program : ::GL.CreateProgram
    end

    def self.CreateShader(type)
      NATIVE_AVAILABLE ? GLNative.create_shader(type) : ::GL.CreateShader(type)
    end

    def self.CullFace(mode)
      NATIVE_AVAILABLE ? GLNative.cull_face(mode) : ::GL.CullFace(mode)
    end

    def self.DepthFunc(func)
      NATIVE_AVAILABLE ? GLNative.depth_func(func) : ::GL.DepthFunc(func)
    end

    def self.DispatchCompute(num_groups_x, num_groups_y, num_groups_z)
      NATIVE_AVAILABLE ? GLNative.dispatch_compute(num_groups_x, num_groups_y, num_groups_z) : ::GL.DispatchCompute(num_groups_x, num_groups_y, num_groups_z)
    end

    def self.DrawArrays(mode, first, count)
      NATIVE_AVAILABLE ? GLNative.draw_arrays(mode, first, count) : ::GL.DrawArrays(mode, first, count)
    end

    def self.DrawBuffer(mode)
      NATIVE_AVAILABLE ? GLNative.draw_buffer(mode) : ::GL.DrawBuffer(mode)
    end

    def self.DrawBuffers(n, bufs)
      NATIVE_AVAILABLE ? GLNative.draw_buffers(n, bufs) : ::GL.DrawBuffers(n, bufs)
    end

    def self.DrawElements(mode, count, type, indices)
      NATIVE_AVAILABLE ? GLNative.draw_elements(mode, count, type, indices) : ::GL.DrawElements(mode, count, type, indices)
    end

    def self.DrawElementsInstanced(mode, count, type, indices, instance_count)
      NATIVE_AVAILABLE ? GLNative.draw_elements_instanced(mode, count, type, indices, instance_count) : ::GL.DrawElementsInstanced(mode, count, type, indices, instance_count)
    end

    def self.EnableVertexAttribArray(index)
      NATIVE_AVAILABLE ? GLNative.enable_vertex_attrib_array(index) : ::GL.EnableVertexAttribArray(index)
    end

    def self.EndQuery(target)
      NATIVE_AVAILABLE ? GLNative.end_query(target) : ::GL.EndQuery(target)
    end

    def self.Finish
      NATIVE_AVAILABLE ? GLNative.finish : ::GL.Finish
    end

    def self.FramebufferTexture2D(target, attachment, textarget, texture, level)
      NATIVE_AVAILABLE ? GLNative.framebuffer_texture_2d(target, attachment, textarget, texture, level) : ::GL.FramebufferTexture2D(target, attachment, textarget, texture, level)
    end

    def self.FramebufferTextureLayer(target, attachment, texture, level, layer)
      NATIVE_AVAILABLE ? GLNative.framebuffer_texture_layer(target, attachment, texture, level, layer) : ::GL.FramebufferTextureLayer(target, attachment, texture, level, layer)
    end

    def self.GenBuffers(n, buffers)
      NATIVE_AVAILABLE ? GLNative.gen_buffers(n, buffers) : ::GL.GenBuffers(n, buffers)
    end

    def self.GenerateMipmap(target)
      NATIVE_AVAILABLE ? GLNative.generate_mipmap(target) : ::GL.GenerateMipmap(target)
    end

    def self.GenFramebuffers(n, framebuffers)
      NATIVE_AVAILABLE ? GLNative.gen_framebuffers(n, framebuffers) : ::GL.GenFramebuffers(n, framebuffers)
    end

    def self.GenQueries(n, ids)
      NATIVE_AVAILABLE ? GLNative.gen_queries(n, ids) : ::GL.GenQueries(n, ids)
    end

    def self.GenTextures(n, textures)
      NATIVE_AVAILABLE ? GLNative.gen_textures(n, textures) : ::GL.GenTextures(n, textures)
    end

    def self.GenVertexArrays(n, arrays)
      NATIVE_AVAILABLE ? GLNative.gen_vertex_arrays(n, arrays) : ::GL.GenVertexArrays(n, arrays)
    end

    def self.GetError
      NATIVE_AVAILABLE ? GLNative.get_error : ::GL.GetError
    end

    def self.GetProgramInfoLog(program, max_length, length, info_log)
      NATIVE_AVAILABLE ? GLNative.get_program_info_log(program, max_length, length, info_log) : ::GL.GetProgramInfoLog(program, max_length, length, info_log)
    end

    def self.GetProgramiv(program, pname, params)
      NATIVE_AVAILABLE ? GLNative.get_programiv(program, pname, params) : ::GL.GetProgramiv(program, pname, params)
    end

    def self.GetQueryObjectui64v(id, pname, params)
      NATIVE_AVAILABLE ? GLNative.get_query_objectui64v(id, pname, params) : ::GL.GetQueryObjectui64v(id, pname, params)
    end

    def self.GetShaderInfoLog(shader, max_length, length, info_log)
      NATIVE_AVAILABLE ? GLNative.get_shader_info_log(shader, max_length, length, info_log) : ::GL.GetShaderInfoLog(shader, max_length, length, info_log)
    end

    def self.GetString(name)
      NATIVE_AVAILABLE ? GLNative.get_string(name) : ::GL.GetString(name)
    end

    def self.GetUniformLocation(program, name)
      NATIVE_AVAILABLE ? GLNative.get_uniform_location(program, name) : ::GL.GetUniformLocation(program, name)
    end

    def self.LinkProgram(program)
      NATIVE_AVAILABLE ? GLNative.link_program(program) : ::GL.LinkProgram(program)
    end

    def self.MemoryBarrier(barriers)
      NATIVE_AVAILABLE ? GLNative.memory_barrier(barriers) : ::GL.MemoryBarrier(barriers)
    end

    def self.ReadBuffer(mode)
      NATIVE_AVAILABLE ? GLNative.read_buffer(mode) : ::GL.ReadBuffer(mode)
    end

    def self.ReadPixels(x, y, width, height, format, type, data)
      NATIVE_AVAILABLE ? GLNative.read_pixels(x, y, width, height, format, type, data) : ::GL.ReadPixels(x, y, width, height, format, type, data)
    end

    def self.ShaderSource(shader, count, string, length)
      NATIVE_AVAILABLE ? GLNative.shader_source(shader, count, string, length) : ::GL.ShaderSource(shader, count, string, length)
    end

    def self.StencilFunc(func, ref, mask)
      NATIVE_AVAILABLE ? GLNative.stencil_func(func, ref, mask) : ::GL.StencilFunc(func, ref, mask)
    end

    def self.StencilMask(mask)
      NATIVE_AVAILABLE ? GLNative.stencil_mask(mask) : ::GL.StencilMask(mask)
    end

    def self.StencilOp(sfail, dpfail, dppass)
      NATIVE_AVAILABLE ? GLNative.stencil_op(sfail, dpfail, dppass) : ::GL.StencilOp(sfail, dpfail, dppass)
    end

    def self.TexImage2D(target, level, internalformat, width, height, border, format, type, data)
      NATIVE_AVAILABLE ? GLNative.tex_image_2d(target, level, internalformat, width, height, border, format, type, data) : ::GL.TexImage2D(target, level, internalformat, width, height, border, format, type, data)
    end

    def self.TexImage3D(target, level, internalformat, width, height, depth, border, format, type, data)
      NATIVE_AVAILABLE ? GLNative.tex_image_3d(target, level, internalformat, width, height, depth, border, format, type, data) : ::GL.TexImage3D(target, level, internalformat, width, height, depth, border, format, type, data)
    end

    def self.TexParameterfv(target, pname, params)
      NATIVE_AVAILABLE ? GLNative.tex_parameterfv(target, pname, params) : ::GL.TexParameterfv(target, pname, params)
    end

    def self.TexParameteri(target, pname, param)
      NATIVE_AVAILABLE ? GLNative.tex_parameteri(target, pname, param) : ::GL.TexParameteri(target, pname, param)
    end

    def self.Uniform1f(location, v0)
      NATIVE_AVAILABLE ? GLNative.uniform1f(location, v0) : ::GL.Uniform1f(location, v0)
    end

    def self.Uniform1i(location, v0)
      NATIVE_AVAILABLE ? GLNative.uniform1i(location, v0) : ::GL.Uniform1i(location, v0)
    end

    def self.Uniform2f(location, v0, v1)
      NATIVE_AVAILABLE ? GLNative.uniform2f(location, v0, v1) : ::GL.Uniform2f(location, v0, v1)
    end

    def self.Uniform3f(location, v0, v1, v2)
      NATIVE_AVAILABLE ? GLNative.uniform3f(location, v0, v1, v2) : ::GL.Uniform3f(location, v0, v1, v2)
    end

    def self.Uniform4f(location, v0, v1, v2, v3)
      NATIVE_AVAILABLE ? GLNative.uniform4f(location, v0, v1, v2, v3) : ::GL.Uniform4f(location, v0, v1, v2, v3)
    end

    def self.UniformMatrix4fv(location, count, transpose, value)
      NATIVE_AVAILABLE ? GLNative.uniform_matrix4fv(location, count, transpose, value) : ::GL.UniformMatrix4fv(location, count, transpose, value)
    end

    def self.VertexAttribDivisor(index, divisor)
      NATIVE_AVAILABLE ? GLNative.vertex_attrib_divisor(index, divisor) : ::GL.VertexAttribDivisor(index, divisor)
    end

    def self.VertexAttribIPointer(index, size, type, stride, pointer)
      NATIVE_AVAILABLE ? GLNative.vertex_attrib_ipointer(index, size, type, stride, pointer) : ::GL.VertexAttribIPointer(index, size, type, stride, pointer)
    end

    def self.VertexAttribPointer(index, size, type, normalized, stride, pointer)
      NATIVE_AVAILABLE ? GLNative.vertex_attrib_pointer(index, size, type, normalized, stride, pointer) : ::GL.VertexAttribPointer(index, size, type, normalized, stride, pointer)
    end

    def self.Viewport(x, y, width, height)
      viewport = [x, y, width, height]
      return if @current_viewport == viewport

      @current_viewport = viewport
      NATIVE_AVAILABLE ? GLNative.viewport(x, y, width, height) : ::GL.Viewport(x, y, width, height)
    end

    def self.load_lib
      ::GL.load_lib
    end

    # Constants (hardcoded OpenGL values)

    ALWAYS = 0x0207
    ARRAY_BUFFER = 0x8892
    BACK = 0x0405
    BLEND = 0x0BE2
    CLAMP_TO_BORDER = 0x812D
    CLAMP_TO_EDGE = 0x812F
    COLOR_ATTACHMENT0 = 0x8CE0
    COLOR_ATTACHMENT1 = 0x8CE1
    COLOR_BUFFER_BIT = 0x4000
    COMPUTE_SHADER = 0x91B9
    CULL_FACE = 0x0B44
    DEPTH24_STENCIL8 = 0x88F0
    DEPTH_ATTACHMENT = 0x8D00
    DEPTH_BUFFER_BIT = 0x0100
    DEPTH_COMPONENT = 0x1902
    DEPTH_COMPONENT32F = 0x8CAC
    DEPTH_STENCIL = 0x84F9
    DEPTH_STENCIL_ATTACHMENT = 0x821A
    DEPTH_STENCIL_TEXTURE_MODE = 0x90EA
    DEPTH_TEST = 0x0B71
    DRAW_FRAMEBUFFER = 0x8CA9
    DYNAMIC_DRAW = 0x88E8
    ELEMENT_ARRAY_BUFFER = 0x8893
    EQUAL = 0x0202
    FALSE = 0
    FLOAT = 0x1406
    FRAGMENT_SHADER = 0x8B30
    FRAMEBUFFER = 0x8D40
    FRAMEBUFFER_COMPLETE = 0x8CD5
    INCR = 0x1E02
    INT = 0x1404
    KEEP = 0x1E00
    LESS = 0x0201
    LINEAR = 0x2601
    LINK_STATUS = 0x8B82
    NEAREST = 0x2600
    NONE = 0
    ONE_MINUS_SRC_ALPHA = 0x0303
    QUERY_RESULT = 0x8866
    READ_FRAMEBUFFER = 0x8CA8
    READ_WRITE = 0x88BA
    REPEAT = 0x2901
    REPLACE = 0x1E01
    RGB = 0x1907
    RGB16F = 0x881B
    RGBA = 0x1908
    RGBA16F = 0x881A
    RGBA32F = 0x8814
    SHADER_IMAGE_ACCESS_BARRIER_BIT = 0x00000020
    SHADING_LANGUAGE_VERSION = 0x8B8C
    SRC_ALPHA = 0x0302
    STATIC_DRAW = 0x88E4
    STENCIL_BUFFER_BIT = 0x0400
    STENCIL_TEST = 0x0B90
    TEXTURE_2D = 0x0DE1
    TEXTURE_2D_ARRAY = 0x8C1A
    TEXTURE_BORDER_COLOR = 0x1004
    TEXTURE_COMPARE_MODE = 0x884C
    TEXTURE_CUBE_MAP = 0x8513
    TEXTURE_CUBE_MAP_ARRAY = 0x9009
    TEXTURE_CUBE_MAP_POSITIVE_X = 0x8515
    TEXTURE_MAG_FILTER = 0x2800
    TEXTURE_MIN_FILTER = 0x2801
    TEXTURE_RECTANGLE = 0x84F5
    TEXTURE_WRAP_R = 0x8072
    TEXTURE_WRAP_S = 0x2802
    TEXTURE_WRAP_T = 0x2803
    TIME_ELAPSED = 0x88BF
    TRIANGLES = 0x0004
    TRUE = 1
    UNSIGNED_BYTE = 0x1401
    UNSIGNED_INT = 0x1405
    UNSIGNED_INT_24_8 = 0x84FA
    VERTEX_SHADER = 0x8B31
    VERSION = 0x1F02

    # Texture units
    TEXTURE0 = 0x84C0
    TEXTURE1 = 0x84C1
    TEXTURE2 = 0x84C2
    TEXTURE3 = 0x84C3
    TEXTURE4 = 0x84C4
    TEXTURE5 = 0x84C5
    TEXTURE6 = 0x84C6
    TEXTURE7 = 0x84C7
    TEXTURE8 = 0x84C8
    TEXTURE9 = 0x84C9
    TEXTURE10 = 0x84CA
    TEXTURE11 = 0x84CB
    TEXTURE12 = 0x84CC
    TEXTURE13 = 0x84CD
    TEXTURE14 = 0x84CE
    TEXTURE15 = 0x84CF
    TEXTURE16 = 0x84D0
    TEXTURE17 = 0x84D1
    TEXTURE18 = 0x84D2
    TEXTURE19 = 0x84D3
    TEXTURE20 = 0x84D4
    TEXTURE21 = 0x84D5
    TEXTURE22 = 0x84D6
    TEXTURE23 = 0x84D7
    TEXTURE24 = 0x84D8
    TEXTURE25 = 0x84D9
    TEXTURE26 = 0x84DA
    TEXTURE27 = 0x84DB
    TEXTURE28 = 0x84DC
    TEXTURE29 = 0x84DD
    TEXTURE30 = 0x84DE
    TEXTURE31 = 0x84DF
  end
end
