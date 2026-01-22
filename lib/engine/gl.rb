module Engine
  module GL

    # Cached methods - avoid redundant GL state changes

    def self.Enable(flag)
      return if enable_flag_cache[flag] == true

      enable_flag_cache[flag] = true
      ::GL.Enable(flag)
    end

    def self.Disable(flag)
      return if enable_flag_cache[flag] == false

      enable_flag_cache[flag] = false
      ::GL.Disable(flag)
    end

    def self.enable_flag_cache
      @enable_flag_cache ||= {}
    end

    def self.UseProgram(program)
      return if @current_program == program

      @current_program = program
      ::GL.UseProgram(program)
    end

    def self.ActiveTexture(texture_unit)
      return if @current_texture_unit == texture_unit

      @current_texture_unit = texture_unit
      ::GL.ActiveTexture(texture_unit)
    end

    def self.BindTexture(target, texture_id)
      cache_key = [@current_texture_unit, target]
      return if bound_textures[cache_key] == texture_id

      bound_textures[cache_key] = texture_id
      ::GL.BindTexture(target, texture_id)
    end

    def self.bound_textures
      @bound_textures ||= {}
    end

    # Pass-through methods

    def self.AttachShader(program, shader)
      ::GL.AttachShader(program, shader)
    end

    def self.BeginQuery(target, id)
      ::GL.BeginQuery(target, id)
    end

    def self.BindBuffer(target, buffer)
      ::GL.BindBuffer(target, buffer)
    end

    def self.BindFramebuffer(target, framebuffer)
      ::GL.BindFramebuffer(target, framebuffer)
    end

    def self.BindImageTexture(unit, texture, level, layered, layer, access, format)
      ::GL.BindImageTexture(unit, texture, level, layered, layer, access, format)
    end

    def self.BindVertexArray(array)
      ::GL.BindVertexArray(array)
    end

    def self.BlendFunc(sfactor, dfactor)
      ::GL.BlendFunc(sfactor, dfactor)
    end

    def self.BlitFramebuffer(src_x0, src_y0, src_x1, src_y1, dst_x0, dst_y0, dst_x1, dst_y1, mask, filter)
      ::GL.BlitFramebuffer(src_x0, src_y0, src_x1, src_y1, dst_x0, dst_y0, dst_x1, dst_y1, mask, filter)
    end

    def self.BufferData(target, size, data, usage)
      ::GL.BufferData(target, size, data, usage)
    end

    def self.BufferSubData(target, offset, size, data)
      ::GL.BufferSubData(target, offset, size, data)
    end

    def self.CheckFramebufferStatus(target)
      ::GL.CheckFramebufferStatus(target)
    end

    def self.Clear(mask)
      ::GL.Clear(mask)
    end

    def self.ClearColor(red, green, blue, alpha)
      ::GL.ClearColor(red, green, blue, alpha)
    end

    def self.ColorMask(red, green, blue, alpha)
      ::GL.ColorMask(red, green, blue, alpha)
    end

    def self.CompileShader(shader)
      ::GL.CompileShader(shader)
    end

    def self.CreateProgram
      ::GL.CreateProgram
    end

    def self.CreateShader(type)
      ::GL.CreateShader(type)
    end

    def self.CullFace(mode)
      ::GL.CullFace(mode)
    end

    def self.DepthFunc(func)
      ::GL.DepthFunc(func)
    end

    def self.DispatchCompute(num_groups_x, num_groups_y, num_groups_z)
      ::GL.DispatchCompute(num_groups_x, num_groups_y, num_groups_z)
    end

    def self.DrawArrays(mode, first, count)
      ::GL.DrawArrays(mode, first, count)
    end

    def self.DrawBuffer(mode)
      ::GL.DrawBuffer(mode)
    end

    def self.DrawBuffers(n, bufs)
      ::GL.DrawBuffers(n, bufs)
    end

    def self.DrawElements(mode, count, type, indices)
      ::GL.DrawElements(mode, count, type, indices)
    end

    def self.DrawElementsInstanced(mode, count, type, indices, instance_count)
      ::GL.DrawElementsInstanced(mode, count, type, indices, instance_count)
    end

    def self.EnableVertexAttribArray(index)
      ::GL.EnableVertexAttribArray(index)
    end

    def self.EndQuery(target)
      ::GL.EndQuery(target)
    end

    def self.Finish
      ::GL.Finish
    end

    def self.FramebufferTexture2D(target, attachment, textarget, texture, level)
      ::GL.FramebufferTexture2D(target, attachment, textarget, texture, level)
    end

    def self.FramebufferTextureLayer(target, attachment, texture, level, layer)
      ::GL.FramebufferTextureLayer(target, attachment, texture, level, layer)
    end

    def self.GenBuffers(n, buffers)
      ::GL.GenBuffers(n, buffers)
    end

    def self.GenerateMipmap(target)
      ::GL.GenerateMipmap(target)
    end

    def self.GenFramebuffers(n, framebuffers)
      ::GL.GenFramebuffers(n, framebuffers)
    end

    def self.GenQueries(n, ids)
      ::GL.GenQueries(n, ids)
    end

    def self.GenTextures(n, textures)
      ::GL.GenTextures(n, textures)
    end

    def self.GenVertexArrays(n, arrays)
      ::GL.GenVertexArrays(n, arrays)
    end

    def self.GetError
      ::GL.GetError
    end

    def self.GetProgramInfoLog(program, max_length, length, info_log)
      ::GL.GetProgramInfoLog(program, max_length, length, info_log)
    end

    def self.GetProgramiv(program, pname, params)
      ::GL.GetProgramiv(program, pname, params)
    end

    def self.GetQueryObjectui64v(id, pname, params)
      ::GL.GetQueryObjectui64v(id, pname, params)
    end

    def self.GetShaderInfoLog(shader, max_length, length, info_log)
      ::GL.GetShaderInfoLog(shader, max_length, length, info_log)
    end

    def self.GetString(name)
      ::GL.GetString(name)
    end

    def self.GetUniformLocation(program, name)
      ::GL.GetUniformLocation(program, name)
    end

    def self.LinkProgram(program)
      ::GL.LinkProgram(program)
    end

    def self.MemoryBarrier(barriers)
      ::GL.MemoryBarrier(barriers)
    end

    def self.ReadBuffer(mode)
      ::GL.ReadBuffer(mode)
    end

    def self.ReadPixels(x, y, width, height, format, type, data)
      ::GL.ReadPixels(x, y, width, height, format, type, data)
    end

    def self.ShaderSource(shader, count, string, length)
      ::GL.ShaderSource(shader, count, string, length)
    end

    def self.StencilFunc(func, ref, mask)
      ::GL.StencilFunc(func, ref, mask)
    end

    def self.StencilMask(mask)
      ::GL.StencilMask(mask)
    end

    def self.StencilOp(sfail, dpfail, dppass)
      ::GL.StencilOp(sfail, dpfail, dppass)
    end

    def self.TexImage2D(target, level, internalformat, width, height, border, format, type, data)
      ::GL.TexImage2D(target, level, internalformat, width, height, border, format, type, data)
    end

    def self.TexImage3D(target, level, internalformat, width, height, depth, border, format, type, data)
      ::GL.TexImage3D(target, level, internalformat, width, height, depth, border, format, type, data)
    end

    def self.TexParameterfv(target, pname, params)
      ::GL.TexParameterfv(target, pname, params)
    end

    def self.TexParameteri(target, pname, param)
      ::GL.TexParameteri(target, pname, param)
    end

    def self.Uniform1f(location, v0)
      ::GL.Uniform1f(location, v0)
    end

    def self.Uniform1i(location, v0)
      ::GL.Uniform1i(location, v0)
    end

    def self.Uniform2f(location, v0, v1)
      ::GL.Uniform2f(location, v0, v1)
    end

    def self.Uniform3f(location, v0, v1, v2)
      ::GL.Uniform3f(location, v0, v1, v2)
    end

    def self.Uniform4f(location, v0, v1, v2, v3)
      ::GL.Uniform4f(location, v0, v1, v2, v3)
    end

    def self.UniformMatrix4fv(location, count, transpose, value)
      ::GL.UniformMatrix4fv(location, count, transpose, value)
    end

    def self.VertexAttribDivisor(index, divisor)
      ::GL.VertexAttribDivisor(index, divisor)
    end

    def self.VertexAttribIPointer(index, size, type, stride, pointer)
      ::GL.VertexAttribIPointer(index, size, type, stride, pointer)
    end

    def self.VertexAttribPointer(index, size, type, normalized, stride, pointer)
      ::GL.VertexAttribPointer(index, size, type, normalized, stride, pointer)
    end

    def self.Viewport(x, y, width, height)
      ::GL.Viewport(x, y, width, height)
    end

    def self.load_lib
      ::GL.load_lib
    end

    # Constants pass-through

    def self.const_missing(name)
      ::GL.const_get(name)
    end
  end
end
