module Engine
  class Component
    def self.method_added(name)
      @methods ||= Set.new
      return if name == :initialize || name == :destroyed?
      @methods.add(name)
    end

    attr_reader :game_object

    def renderer?
      false
    end

    def ui_renderer?
      false
    end

    def set_game_object(game_object)
      @game_object = game_object
    end

    def start
    end

    def update(delta_time) end

    def destroyed?
      @destroyed || false
    end

    def destroy!
      Component.destroyed_components << self unless @destroyed
      destroy unless @destroyed
      @destroyed = true
    end

    def _erase!
      game_object.components.delete(self)
      class_name = self.class.name.split('::').last
      self.class.instance_variable_get(:@methods).each do |method|
        singleton_class.send(:undef_method, method)
        singleton_class.send(:define_method, method) do |*args, **kwargs|
          raise "This #{class_name} has been destroyed but you are still trying to access #{method}"
        end
      end
    end

    def self.erase_destroyed_components
      destroyed_components.each do |object|
        object._erase!
      end
      @destroyed_components = []
    end

    def destroy
    end

    def self.destroyed_components
      @destroyed_components ||= []
    end
  end
end
