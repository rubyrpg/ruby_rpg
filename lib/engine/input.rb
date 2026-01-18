# frozen_string_literal: true

module Engine
  class Input
    def self.init
      @key_callback = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
        Input.key_callback(key, action)
      end
      GLFW.SetKeyCallback(Window.window, @key_callback)

      @cursor_pos_callback = GLFW::create_callback(:GLFWcursorposfun) do |window, x, y|
        Input.mouse_callback(x, y)
      end
      GLFW.SetCursorPosCallback(Window.window, @cursor_pos_callback)

      @mouse_button_callback = GLFW::create_callback(:GLFWmousebuttonfun) do |window, button, action, mods|
        Input.mouse_button_callback(button, action)
      end
      GLFW.SetMouseButtonCallback(Window.window, @mouse_button_callback)
    end

    def self.key?(key)
      keys[key] == :down || keys[key] == :held
    end

    def self.key_down?(key)
      keys[key] == :down
    end

    def self.key_up?(key)
      keys[key] == :up
    end

    def self.mouse_pos
      @mouse_pos
    end

    def self.mouse_delta
      return Vector[0, 0] if @old_mouse_pos.nil?
      return Vector[0, 0] unless @mouse_pos_updated

      @mouse_pos - @old_mouse_pos
    end

    def self._on_key_down(key)
      keys[key] = :down
      if key == GLFW::KEY_ESCAPE
        Engine.close
      end

      if key == GLFW::KEY_BACKSPACE
        Engine::Debugging.breakpoint { binding.pry }
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

    def self.mouse_callback(x, y)
      @mouse_pos_updated = true
      @old_mouse_pos = @mouse_pos
      # Y-down coordinate system: use GLFW y directly
      @mouse_pos = Vector[x, y]
    end

    def self.mouse_button_callback(button, action)
      if action == GLFW::PRESS
        keys[button] = :down
      elsif action == GLFW::RELEASE
        keys[button] = :up
      end
    end

    def self.update_key_states
      @mouse_pos_updated = false
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
