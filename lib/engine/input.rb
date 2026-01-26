# frozen_string_literal: true

module Engine
  class Input
    # Key action constants
    RELEASE = 0
    PRESS = 1
    REPEAT = 2

    # Keyboard keys
    KEY_SPACE = 32
    KEY_APOSTROPHE = 39
    KEY_COMMA = 44
    KEY_MINUS = 45
    KEY_PERIOD = 46
    KEY_SLASH = 47
    KEY_0 = 48
    KEY_1 = 49
    KEY_2 = 50
    KEY_3 = 51
    KEY_4 = 52
    KEY_5 = 53
    KEY_6 = 54
    KEY_7 = 55
    KEY_8 = 56
    KEY_9 = 57
    KEY_SEMICOLON = 59
    KEY_EQUAL = 61
    KEY_A = 65
    KEY_B = 66
    KEY_C = 67
    KEY_D = 68
    KEY_E = 69
    KEY_F = 70
    KEY_G = 71
    KEY_H = 72
    KEY_I = 73
    KEY_J = 74
    KEY_K = 75
    KEY_L = 76
    KEY_M = 77
    KEY_N = 78
    KEY_O = 79
    KEY_P = 80
    KEY_Q = 81
    KEY_R = 82
    KEY_S = 83
    KEY_T = 84
    KEY_U = 85
    KEY_V = 86
    KEY_W = 87
    KEY_X = 88
    KEY_Y = 89
    KEY_Z = 90
    KEY_LEFT_BRACKET = 91
    KEY_BACKSLASH = 92
    KEY_RIGHT_BRACKET = 93
    KEY_GRAVE_ACCENT = 96
    KEY_ESCAPE = 256
    KEY_ENTER = 257
    KEY_TAB = 258
    KEY_BACKSPACE = 259
    KEY_INSERT = 260
    KEY_DELETE = 261
    KEY_RIGHT = 262
    KEY_LEFT = 263
    KEY_DOWN = 264
    KEY_UP = 265
    KEY_PAGE_UP = 266
    KEY_PAGE_DOWN = 267
    KEY_HOME = 268
    KEY_END = 269
    KEY_CAPS_LOCK = 280
    KEY_SCROLL_LOCK = 281
    KEY_NUM_LOCK = 282
    KEY_PRINT_SCREEN = 283
    KEY_PAUSE = 284
    KEY_F1 = 290
    KEY_F2 = 291
    KEY_F3 = 292
    KEY_F4 = 293
    KEY_F5 = 294
    KEY_F6 = 295
    KEY_F7 = 296
    KEY_F8 = 297
    KEY_F9 = 298
    KEY_F10 = 299
    KEY_F11 = 300
    KEY_F12 = 301
    KEY_LEFT_SHIFT = 340
    KEY_LEFT_CONTROL = 341
    KEY_LEFT_ALT = 342
    KEY_LEFT_SUPER = 343
    KEY_RIGHT_SHIFT = 344
    KEY_RIGHT_CONTROL = 345
    KEY_RIGHT_ALT = 346
    KEY_RIGHT_SUPER = 347

    # Mouse buttons
    MOUSE_BUTTON_1 = 0
    MOUSE_BUTTON_2 = 1
    MOUSE_BUTTON_3 = 2
    MOUSE_BUTTON_4 = 3
    MOUSE_BUTTON_5 = 4
    MOUSE_BUTTON_6 = 5
    MOUSE_BUTTON_7 = 6
    MOUSE_BUTTON_8 = 7
    MOUSE_BUTTON_LEFT = MOUSE_BUTTON_1
    MOUSE_BUTTON_RIGHT = MOUSE_BUTTON_2
    MOUSE_BUTTON_MIDDLE = MOUSE_BUTTON_3

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
      if key == KEY_ESCAPE
        Engine.close
      end

      if key == KEY_BACKSPACE
        Engine::Debugging.breakpoint { binding.pry }
        # Engine.breakpoint { debugger }
      end

      if key == KEY_F
        Engine::Window.toggle_full_screen
      end
    end

    def self._on_key_up(key)
      keys[key] = :up
    end

    def self.key_callback(key, action)
      if action == PRESS
        _on_key_down(key)
      elsif action == RELEASE
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
      if action == PRESS
        keys[button] = :down
      elsif action == RELEASE
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
