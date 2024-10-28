# frozen_string_literal: true

module Engine
  module Debugging

    # Hit a breakpoint within the context of where the breakpoint is defined, assuming a block is passed
    # with a `binding.pry` (or an alternative debugger), otherwise hit a breakpoint within this method.
    def self.breakpoint(&block)
      orig_fullscreen = Window.full_screen?
      if orig_fullscreen
        Window.set_to_windowed
        GLFW.PollEvents # Required to trigger the switch from fullscreen to windowed within this breakpoint
      end

      orig_cursor_mode = Cursor.get_input_mode
      Cursor.enable

      block_given? ? yield : binding.pry
      Cursor.restore_input_mode(orig_cursor_mode)
      Window.set_to_full_screen if orig_fullscreen
      Window.focus_window

      # Reset the time, otherwise delta_time will be off for the next frame, and teleporting occurs
      @time = Time.now
    end

    def self.debug_opengl_call
      errors = []
      until GL.GetError == 0; end
      yield
      until (error = GL.GetError) == 0
        errors += error.to_s(16)
      end
    end

    def self.print_opengl_version
      puts "OpenGL Version: #{GL.GetString(GL::VERSION)}"
      puts "GLSL Version: #{GL.GetString(GL::SHADING_LANGUAGE_VERSION)}"
    end
  end
end
