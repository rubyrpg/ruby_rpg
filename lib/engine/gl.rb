module Engine
  module GL
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
