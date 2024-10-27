# frozen_string_literal: true

module Engine
  class Window

    DEFAULT_TITLE = File.basename($PROGRAM_NAME).gsub(/\.rb$/,'')

    class << self
      attr_accessor :full_screen, :window, :window_title
      attr_reader :framebuffer_height, :framebuffer_width

      def create_window
        set_opengl_version
        decorations :disable
        auto_iconify :disable
        @full_screen = true
        initial_video_mode = VideoMode.current_video_mode
        @window = GLFW.CreateWindow(
          initial_video_mode.width, initial_video_mode.height, DEFAULT_TITLE, primary_monitor, nil
        )
      end

      alias full_screen? full_screen

      def width
        max_width = VideoMode.current_video_mode.width
        @width = full_screen? ? max_width : max_width * 0.8
      end

      def height
        max_height = VideoMode.current_video_mode.height
        @height = full_screen? ? max_height : max_height * 0.8
      end

      def monitor
        full_screen? ? primary_monitor : nil
      end

      def set_title(title)
        GLFW::SetWindowTitle(window, title)
      end

      def primary_monitor
        # The primary monitor is returned by glfwGetPrimaryMonitor.
        # It is the user's preferred monitor and is usually the one with global UI elements like task bar or menu bar.
        # https://www.glfw.org/docs/latest/monitor_guide.html#monitor_monitors
        GLFW.GetPrimaryMonitor
      end

      def refresh_rate
        # GLFW_REFRESH_RATE specifies the desired refresh rate for full screen windows.
        # A value of GLFW_DONT_CARE means the highest available refresh rate will be used.
        # This hint is ignored for windowed mode windows.
        # https://www.glfw.org/docs/latest/window_guide.html#GLFW_REFRESH_RATE
        GLFW::DONT_CARE
      end

      def decorations(state)
        # GLFW_DECORATED specifies whether the windowed mode window will have window decorations such as a border,
        # a close widget, etc.
        # An undecorated window will not be resizable by the user but will still allow the user to generate close events
        # on some platforms.
        # Possible values are GLFW_TRUE and GLFW_FALSE.
        # This hint is ignored for full screen windows.
        # https://www.glfw.org/docs/latest/window_guide.html#GLFW_DECORATED_attrib
        glfw_setting = translate_state[state]

        GLFW.WindowHint(GLFW::DECORATED, glfw_setting)
        GLFW.SetWindowAttrib(window, GLFW::DECORATED, glfw_setting) if window
      end

      def auto_iconify(state)
        # GLFW_AUTO_ICONIFY specifies whether the full screen window will automatically iconify and restore the previous
        # video mode on input focus loss.
        # Possible values are GLFW_TRUE and GLFW_FALSE.
        # This hint is ignored for windowed mode windows.
        # https://www.glfw.org/docs/latest/window_guide.html#GLFW_AUTO_ICONIFY_hint
        glfw_setting = translate_state[state]

        GLFW.WindowHint(GLFW::AUTO_ICONIFY, glfw_setting)
        GLFW.SetWindowAttrib(window, GLFW::AUTO_ICONIFY, glfw_setting) if window
      end

      def set_to_windowed
        @full_screen = false
        GLFW.SetWindowMonitor(window, nil, 0, 0, width, height, refresh_rate)
      end

      def set_to_full_screen
        @full_screen = true
        GLFW.SetWindowMonitor(window, primary_monitor, 0, 0, width, height, refresh_rate)
      end

      def toggle_full_screen
        full_screen? ? set_to_windowed : set_to_full_screen
      end

      def focus_window
        GLFW.FocusWindow(window)
      end

      def get_framebuffer_size
        width_buf = ' ' * 8
        height_buf = ' ' * 8

        GLFW.GetFramebufferSize(window, width_buf, height_buf)
        @framebuffer_width = width_buf.unpack1('L')
        @framebuffer_height = height_buf.unpack1('L')
      end

      def set_opengl_version
        GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 3)
        GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 3)
        GLFW.WindowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)
        GLFW.WindowHint(GLFW::OPENGL_FORWARD_COMPAT, GLFW::TRUE)
      end

      def translate_state
        {
          :enable   => GLFW::TRUE,
          :disable  => GLFW::FALSE
        }
      end
    end
  end
end
