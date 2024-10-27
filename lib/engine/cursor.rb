# frozen_string_literal: true

module Engine
  class Cursor
    class << self

      def supported_modes
        {
          :enable   => GLFW::CURSOR_NORMAL,
          :disable  => GLFW::CURSOR_DISABLED,
          :hide     => GLFW::CURSOR_HIDDEN
        }
      end

      def enable
        set_input_mode(:enable)
      end

      def disable
        set_input_mode(:disable)
      end

      def hide
        set_input_mode(:hide)
      end

      # Expects a symbol present in supported_modes, e.g. ':hide'
      def set_input_mode(mode)
        GLFW.SetInputMode(Window.window, GLFW::CURSOR, supported_modes[mode])
      end

      # Returns a symbol from the supported_modes, e.g. ':hide'
      def get_input_mode
        supported_modes.key(GLFW.GetInputMode(Window.window, GLFW::CURSOR))
      end

      # Expects a symbol present in supported_modes, e.g. ':hide'
      def restore_input_mode(original_mode)
        set_input_mode(original_mode)
      end
    end
  end
end
