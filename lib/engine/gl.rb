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

    # Constants

    ALWAYS = ::GL::ALWAYS
    ARRAY_BUFFER = ::GL::ARRAY_BUFFER
    BACK = ::GL::BACK
    BLEND = ::GL::BLEND
    CLAMP_TO_BORDER = ::GL::CLAMP_TO_BORDER
    CLAMP_TO_EDGE = ::GL::CLAMP_TO_EDGE
    COLOR_ATTACHMENT0 = ::GL::COLOR_ATTACHMENT0
    COLOR_ATTACHMENT1 = ::GL::COLOR_ATTACHMENT1
    COLOR_BUFFER_BIT = ::GL::COLOR_BUFFER_BIT
    COMPUTE_SHADER = ::GL::COMPUTE_SHADER
    CULL_FACE = ::GL::CULL_FACE
    DEPTH24_STENCIL8 = ::GL::DEPTH24_STENCIL8
    DEPTH_ATTACHMENT = ::GL::DEPTH_ATTACHMENT
    DEPTH_BUFFER_BIT = ::GL::DEPTH_BUFFER_BIT
    DEPTH_COMPONENT = ::GL::DEPTH_COMPONENT
    DEPTH_COMPONENT32F = ::GL::DEPTH_COMPONENT32F
    DEPTH_STENCIL = ::GL::DEPTH_STENCIL
    DEPTH_STENCIL_ATTACHMENT = ::GL::DEPTH_STENCIL_ATTACHMENT
    DEPTH_STENCIL_TEXTURE_MODE = ::GL::DEPTH_STENCIL_TEXTURE_MODE
    DEPTH_TEST = ::GL::DEPTH_TEST
    DRAW_FRAMEBUFFER = ::GL::DRAW_FRAMEBUFFER
    DYNAMIC_DRAW = ::GL::DYNAMIC_DRAW
    ELEMENT_ARRAY_BUFFER = ::GL::ELEMENT_ARRAY_BUFFER
    EQUAL = ::GL::EQUAL
    FALSE = ::GL::FALSE
    FLOAT = ::GL::FLOAT
    FRAGMENT_SHADER = ::GL::FRAGMENT_SHADER
    FRAMEBUFFER = ::GL::FRAMEBUFFER
    FRAMEBUFFER_COMPLETE = ::GL::FRAMEBUFFER_COMPLETE
    INCR = ::GL::INCR
    INT = ::GL::INT
    KEEP = ::GL::KEEP
    LESS = ::GL::LESS
    LINEAR = ::GL::LINEAR
    LINK_STATUS = ::GL::LINK_STATUS
    NEAREST = ::GL::NEAREST
    NONE = ::GL::NONE
    ONE_MINUS_SRC_ALPHA = ::GL::ONE_MINUS_SRC_ALPHA
    QUERY_RESULT = ::GL::QUERY_RESULT
    READ_FRAMEBUFFER = ::GL::READ_FRAMEBUFFER
    READ_WRITE = ::GL::READ_WRITE
    REPEAT = ::GL::REPEAT
    REPLACE = ::GL::REPLACE
    RGB = ::GL::RGB
    RGB16F = ::GL::RGB16F
    RGBA = ::GL::RGBA
    RGBA16F = ::GL::RGBA16F
    RGBA32F = ::GL::RGBA32F
    SHADER_IMAGE_ACCESS_BARRIER_BIT = ::GL::SHADER_IMAGE_ACCESS_BARRIER_BIT
    SHADING_LANGUAGE_VERSION = ::GL::SHADING_LANGUAGE_VERSION
    SRC_ALPHA = ::GL::SRC_ALPHA
    STATIC_DRAW = ::GL::STATIC_DRAW
    STENCIL_BUFFER_BIT = ::GL::STENCIL_BUFFER_BIT
    STENCIL_TEST = ::GL::STENCIL_TEST
    TEXTURE_2D = ::GL::TEXTURE_2D
    TEXTURE_2D_ARRAY = ::GL::TEXTURE_2D_ARRAY
    TEXTURE_BORDER_COLOR = ::GL::TEXTURE_BORDER_COLOR
    TEXTURE_COMPARE_MODE = ::GL::TEXTURE_COMPARE_MODE
    TEXTURE_CUBE_MAP = ::GL::TEXTURE_CUBE_MAP
    TEXTURE_CUBE_MAP_ARRAY = ::GL::TEXTURE_CUBE_MAP_ARRAY
    TEXTURE_CUBE_MAP_POSITIVE_X = ::GL::TEXTURE_CUBE_MAP_POSITIVE_X
    TEXTURE_MAG_FILTER = ::GL::TEXTURE_MAG_FILTER
    TEXTURE_MIN_FILTER = ::GL::TEXTURE_MIN_FILTER
    TEXTURE_RECTANGLE = ::GL::TEXTURE_RECTANGLE
    TEXTURE_WRAP_R = ::GL::TEXTURE_WRAP_R
    TEXTURE_WRAP_S = ::GL::TEXTURE_WRAP_S
    TEXTURE_WRAP_T = ::GL::TEXTURE_WRAP_T
    TIME_ELAPSED = ::GL::TIME_ELAPSED
    TRIANGLES = ::GL::TRIANGLES
    TRUE = ::GL::TRUE
    UNSIGNED_BYTE = ::GL::UNSIGNED_BYTE
    UNSIGNED_INT = ::GL::UNSIGNED_INT
    UNSIGNED_INT_24_8 = ::GL::UNSIGNED_INT_24_8
    VERTEX_SHADER = ::GL::VERTEX_SHADER
    VERSION = ::GL::VERSION

    # Texture units
    TEXTURE0 = ::GL::TEXTURE0
    TEXTURE1 = ::GL::TEXTURE1
    TEXTURE2 = ::GL::TEXTURE2
    TEXTURE3 = ::GL::TEXTURE3
    TEXTURE4 = ::GL::TEXTURE4
    TEXTURE5 = ::GL::TEXTURE5
    TEXTURE6 = ::GL::TEXTURE6
    TEXTURE7 = ::GL::TEXTURE7
    TEXTURE8 = ::GL::TEXTURE8
    TEXTURE9 = ::GL::TEXTURE9
    TEXTURE10 = ::GL::TEXTURE10
    TEXTURE11 = ::GL::TEXTURE11
    TEXTURE12 = ::GL::TEXTURE12
    TEXTURE13 = ::GL::TEXTURE13
    TEXTURE14 = ::GL::TEXTURE14
    TEXTURE15 = ::GL::TEXTURE15
    TEXTURE16 = ::GL::TEXTURE16
    TEXTURE17 = ::GL::TEXTURE17
    TEXTURE18 = ::GL::TEXTURE18
    TEXTURE19 = ::GL::TEXTURE19
    TEXTURE20 = ::GL::TEXTURE20
    TEXTURE21 = ::GL::TEXTURE21
    TEXTURE22 = ::GL::TEXTURE22
    TEXTURE23 = ::GL::TEXTURE23
    TEXTURE24 = ::GL::TEXTURE24
    TEXTURE25 = ::GL::TEXTURE25
    TEXTURE26 = ::GL::TEXTURE26
    TEXTURE27 = ::GL::TEXTURE27
    TEXTURE28 = ::GL::TEXTURE28
    TEXTURE29 = ::GL::TEXTURE29
    TEXTURE30 = ::GL::TEXTURE30
    TEXTURE31 = ::GL::TEXTURE31
  end
end
