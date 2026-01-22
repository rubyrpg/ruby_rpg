module Engine
  module GL

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

    def self.method_missing(name, *args, &block)
      ::GL.send(name, *args, &block)
    end

    def self.respond_to_missing?(name, include_private = false)
      ::GL.respond_to?(name) || super
    end

    def self.const_missing(name)
      ::GL.const_get(name)
    end
  end
end
