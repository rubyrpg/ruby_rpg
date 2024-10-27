# frozen_string_literal: true

module Engine
  class Input
    def self.key?(key)
      keys[key] == :down || keys[key] == :held
    end

    def self.key_down?(key)
      keys[key] == :down
    end

    def self.key_up?(key)
      keys[key] == :up
    end

    def self._on_key_down(key)
      keys[key] = :down
      if key == GLFW::KEY_ESCAPE
        Engine.close
      end

      if key == GLFW::KEY_BACKSPACE
        Engine.breakpoint { binding.pry }
        # Engine.breakpoint { debugger }
      end

      if key == GLFW::KEY_F
        Engine::Window.toggle_full_screen
      end
    end

    def self._on_key_up(key)
      keys[key] = :up
    end

    def self.key_callback(key, action)
      if action == GLFW::PRESS
        _on_key_down(key)
      elsif action == GLFW::RELEASE
        _on_key_up(key)
      end
    end

    def self.update_key_states
      keys.each do |key, state|
        if state == :down
          keys[key] = :held
        elsif state == :up
          keys.delete(key)
        end
      end
    end

    private

    def self.keys
      @keys ||= {}
    end
  end
end
